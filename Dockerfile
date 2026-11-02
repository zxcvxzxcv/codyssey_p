# 1. nginx 공식 이미지를 베이스로 사용
FROM nginx:latest

# 2. 내가 만든 index.html을 nginx 기본 웹 폴더로 복사
COPY site/ /usr/share/nginx/html/