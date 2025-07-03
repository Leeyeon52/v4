    # C:\Users\sptzk\Desktop\backend\app.py
from flask import Flask
from flask_cors import CORS
from models import db # models.py에서 db 객체 임포트
from config import Config # config.py에서 Config 클래스 임포트
from routes.auth_routes import auth_bp # auth_routes.py에서 auth_bp 임포트

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config) # config.py에서 설정 로드

    CORS(app) # 모든 Origin에 대해 CORS 허용
    db.init_app(app) # Flask 앱에 SQLAlchemy db 객체 초기화

    app.register_blueprint(auth_bp, url_prefix='/auth') # 인증 관련 라우트 블루프린트 등록

    return app

if __name__ == '__main__':
    app = create_app()
    with app.app_context():
        # 애플리케이션 컨텍스트 내에서 데이터베이스 테이블 생성
        # 이 코드는 서버가 처음 시작될 때만 실행되어야 합니다.
        # 테이블이 이미 존재하면 오류가 발생하지 않지만,
        # 프로덕션 환경에서는 마이그레이션 도구를 사용하는 것이 좋습니다.
        db.create_all()
        print("데이터베이스 테이블이 생성되었는지 확인했습니다.")
    
    # ✅ 이 부분을 수정해야 합니다: host='0.0.0.0' 추가
    # 이렇게 하면 Flask 서버가 로컬 네트워크의 모든 IP 주소에서 접근 가능해집니다.
    # debug=True는 개발 중 코드 변경 시 자동 재시작 기능을 활성화합니다.
    app.run(debug=True, host='0.0.0.0', port=5000)