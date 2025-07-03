from flask import Blueprint, request, jsonify
from models import db, UserLogin, UserInfo
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.json
    user_id = data.get('user_id')

    if not user_id:
        return jsonify({'error': 'user_id 누락'}), 400

    if UserLogin.query.get(user_id):
        return jsonify({'error': '이미 존재하는 아이디입니다'}), 409

    hashed_pw = generate_password_hash(data['password'])

    user_login = UserLogin(
        user_id=user_id,
        password=hashed_pw,
        created_at=datetime.utcnow()
    )

    # Flutter 앱에서 'birth'는 'YYYY-MM-DD' 형식의 문자열로 전송됨
    birth_str = data.get('birth', '2000-01-01')
    try:
        birth_date = datetime.strptime(birth_str, '%Y-%m-%d').date()
    except ValueError:
        return jsonify({'error': '잘못된 생년월일 형식입니다. YYYY-MM-DD 형식으로 입력해주세요.'}), 400

    user_info = UserInfo(
        user_id=user_id,
        name=data.get('name', ''),
        gender=data.get('gender', ''),
        birth=birth_date,
        phone=data.get('phone', ''),
        address='' # 주소 필드는 현재 사용하지 않으므로 빈 문자열로 초기화
    )

    db.session.add(user_login)
    db.session.add(user_info)
    db.session.commit()

    return jsonify({'message': '회원가입 성공'}), 201

@auth_bp.route('/exists', methods=['GET'])
def check_user_exists():
    user_id = request.args.get('user_id')
    if not user_id:
        return jsonify({'error': 'user_id 쿼리 파라미터가 필요합니다'}), 400

    exists = UserLogin.query.get(user_id) is not None
    return jsonify({'exists': exists})

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    user_id = data.get('user_id')
    password = data.get('password')

    if not user_id or not password:
        return jsonify({'error': '아이디와 비밀번호를 입력하세요'}), 400

    user_login = UserLogin.query.get(user_id)
    # 사용자 존재 여부 및 비밀번호 일치 여부 확인
    if not user_login or not check_password_hash(user_login.password, password):
        return jsonify({'error': '잘못된 아이디 또는 비밀번호입니다'}), 401
    
    # UserInfo에서 추가 정보 가져오기
    user_info = UserInfo.query.get(user_id)
    if not user_info:
        # 로그인 성공했으나 사용자 정보가 없는 경우 (데이터 불일치)
        return jsonify({'error': '사용자 정보를 찾을 수 없습니다'}), 404

    # 로그인 성공 시 사용자 정보 반환
    return jsonify({
        'message': '로그인 성공',
        'user': {
            'user_id': user_info.user_id,
            'name': user_info.name,
            'gender': user_info.gender,
            'birth': user_info.birth.strftime('%Y-%m-%d'), # Date 객체를 문자열로 포맷팅
            'phone': user_info.phone,
            'address': user_info.address # address 필드도 포함
        }
    }), 200

# ✅ 회원 탈퇴 엔드포인트 추가
@auth_bp.route('/delete_account', methods=['DELETE'])
def delete_account():
    data = request.json
    user_id = data.get('user_id')
    password = data.get('password') # 보안을 위해 비밀번호 재확인

    if not user_id or not password:
        return jsonify({'error': '아이디와 비밀번호를 입력하세요'}), 400

    user_login = UserLogin.query.get(user_id)
    if not user_login:
        return jsonify({'error': '존재하지 않는 아이디입니다'}), 404
    
    # 비밀번호 일치 여부 확인
    if not check_password_hash(user_login.password, password):
        return jsonify({'error': '비밀번호가 일치하지 않습니다'}), 401

    try:
        # UserInfo 먼저 삭제 (외래 키 제약 조건 때문에 UserLogin보다 먼저 삭제해야 함)
        user_info = UserInfo.query.get(user_id)
        if user_info:
            db.session.delete(user_info)
        
        # UserLogin 삭제
        db.session.delete(user_login)
        db.session.commit()
        return jsonify({'message': '회원 탈퇴 성공'}), 200
    except Exception as e:
        db.session.rollback() # 오류 발생 시 롤백
        # 디버깅을 위해 서버 콘솔에 오류 출력
        print(f"회원 탈퇴 중 오류 발생: {e}") 
        return jsonify({'error': f'회원 탈퇴 중 서버 오류 발생: {str(e)}'}), 500