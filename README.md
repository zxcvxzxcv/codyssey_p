# 내 컴퓨터에 개발자용 '작업실' 꾸미기

> 터미널 · Docker(OrbStack) · Git/GitHub 로 재현 가능한 개발 환경을 만들고, 모든 과정을 로그와 증거로 남긴 기술 문서입니다.

> ⚠️ **작성 가이드**: `TODO`로 표시된 곳을 실제 출력/스크린샷으로 채운 뒤 이 안내 문구는 지우세요. 모든 출력은 직접 실행한 결과로 채워야 합니다.

---

## 1. 프로젝트 개요

**미션 목표**
- 리눅스 CLI로 작업 디렉토리와 파일 권한을 다룬다.
- Docker를 설치·점검하고 컨테이너를 실행·관리한다.
- Dockerfile로 커스텀 이미지를 만들고, 포트 매핑·바인드 마운트·볼륨으로 접속, 변경 반영, 데이터 영속성을 검증한다.
- Git/GitHub를 설정하고 VSCode와 연동한다.

**서울캠퍼스 환경 참고**: 보안 정책상 `sudo` 사용이 제한되므로 Docker Desktop 대신 **OrbStack**을 사용했습니다. OrbStack 실행 시 Docker 엔진이 함께 구동되며, 터미널에서는 일반 `docker` 명령을 그대로 사용합니다.

---

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| OS | macOS (Apple Silicon, aarch64) |
| Shell / Terminal | zsh / VSCode 통합 터미널 |
| Docker | 29.8.2 (build 7fc2dff), Context: `orbstack` |
| Docker Compose | v5.5.0 |
| Docker Buildx | v0.37.2 |
| Git | TODO (`git --version` 결과) |
| 에디터 | VSCode |

```bash
$ docker --version
Docker version 29.8.2, build 7fc2dff
```

```bash
$ git --version
TODO
```

---

## 3. 수행 체크리스트

- [ ] 터미널 기본 조작 (위치/목록/이동/생성/복사/이동·이름변경/삭제/내용 확인)
- [ ] 권한 변경 실습 (파일 1개 + 디렉토리 1개)
- [x] Docker 설치/점검 (`docker --version`, `docker info`)
- [ ] 이미지/컨테이너 기본 운영 (`images`, `ps`, `ps -a`, `logs`, `stats`)
- [ ] `hello-world` 실행
- [x] `ubuntu` 컨테이너 실행 및 내부 명령 수행
- [ ] 컨테이너 종료/유지 (`run -it` / `attach` / `exec`) 관찰
- [ ] Dockerfile 작성 및 커스텀 이미지 빌드/실행
- [ ] 포트 매핑 접속 (8080, 8081 두 번)
- [ ] 바인드 마운트 변경 반영
- [ ] Docker 볼륨 영속성 검증
- [ ] Git 설정 (`git config --list`)
- [ ] VSCode GitHub 로그인 및 저장소 연동
- [ ] (보너스) Compose / 환경변수 / SSH 키

---

## 4. 검증 방법 요약

| 항목 | 사용한 명령 | 확인한 것 | 결과 위치 |
|---|---|---|---|
| Docker 설치 | `docker --version` | 버전 출력 | [5-3](#5-3-docker-설치-및-점검) |
| 데몬 동작 | `docker info` | Server 항목 정상 출력 | [5-3](#5-3-docker-설치-및-점검) |
| 컨테이너 실행 | `docker run hello-world`, `docker run -it ubuntu bash` | 실행 성공, 내부 진입 | [5-5](#5-5-컨테이너-실행-실습) |
| 포트 매핑 | `docker run -p 8080:80`, `curl localhost:8080` | 호스트 포트로 응답 수신 | [5-7](#5-7-포트-매핑) |
| 바인드 마운트 | `-v $(pwd)/site:/usr/share/nginx/html` | 호스트 파일 수정이 즉시 반영 | [5-8](#5-8-바인드-마운트) |
| 볼륨 영속성 | `docker volume create`, 컨테이너 삭제 후 재연결 | 데이터 유지 | [5-9](#5-9-docker-볼륨-영속성) |
| Git 설정 | `git config --list` | 사용자 정보/기본 브랜치 | [5-10](#5-10-git-설정-및-github-연동) |

---

## 5. 수행 로그

### 5-1. 터미널 기본 조작

```bash
$ pwd
TODO
$ mkdir -p ~/codyssey/practice && cd ~/codyssey/practice
$ ls -la
TODO
$ touch a.txt
$ echo "hello" > b.txt
$ cat b.txt
hello
$ cp b.txt c.txt
$ mv c.txt d.txt          # 이름 변경
$ mkdir sub && mv d.txt sub/   # 이동
$ ls -la . sub
TODO
$ rm a.txt
$ rm -r sub
$ ls -la
TODO
```

### 5-2. 권한 실습

**파일**
```bash
$ touch perm.txt
$ ls -l perm.txt          # 변경 전
TODO
$ chmod 600 perm.txt
$ ls -l perm.txt          # 변경 후
TODO
```

**디렉토리**
```bash
$ mkdir permdir
$ ls -ld permdir          # 변경 전
TODO
$ chmod 700 permdir
$ ls -ld permdir          # 변경 후
TODO
```

**관찰**: TODO (예: 디렉토리에서 `x`가 없으면 `cd`가 막히는지 직접 실험한 결과)

### 5-3. Docker 설치 및 점검

```bash
$ docker --version
Docker version 29.8.2, build 7fc2dff
```

```bash
$ docker info        # 발췌
Client:
 Version:    29.8.2
 Context:    orbstack
 Debug Mode: false
 Plugins:
  buildx: Docker Buildx (Docker Inc.)
    Version:  v0.37.2
  compose: Docker Compose (Docker Inc.)
    Version:  v5.5.0

Server:
 Server Version: 29.8.2
 Storage Driver: overlayfs
 Logging Driver: json-file
 Cgroup Version: 2
 Runtimes: io.containerd.runc.v2 runc
 Default Runtime: runc
 Kernel Version: 7.2.12-orbstack-00394-gbecdd6130068
 Operating System: OrbStack
 OSType: linux
 Architecture: aarch64
 CPUs: 10
 Total Memory: 7.816GiB
 ...
WARNING: DOCKER_INSECURE_NO_IPTABLES_RAW is set
```

> `DOCKER_INSECURE_NO_IPTABLES_RAW` 경고는 OrbStack 환경에서 나타나는 설정 관련 안내이며 동작에는 영향이 없었습니다.
>
> 데몬이 정상 동작하므로 `Server:` 항목이 출력됩니다. (데몬이 꺼져 있으면 `Cannot connect to the Docker daemon` 오류가 나옵니다.)

### 5-4. 이미지/컨테이너 기본 운영

```bash
$ docker images
TODO
$ docker ps
TODO
$ docker ps -a
TODO
$ docker run -d --name sleeper ubuntu sleep infinity
$ docker logs sleeper
TODO (sleep은 출력이 없어 비어 있음)
$ docker stats --no-stream
TODO
$ docker stop sleeper
$ docker ps -a
TODO
```

로그 출력 예시:
```bash
$ docker run -d --name logger ubuntu bash -c 'for i in 1 2 3; do echo "log $i"; sleep 1; done'
$ docker logs logger
TODO
```

### 5-5. 컨테이너 실행 실습

**hello-world**
```bash
$ docker run hello-world
TODO
```

**ubuntu 컨테이너 진입**
```bash
$ docker run -it --name ubuntu-test ubuntu bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
6f01cc7d6fb3: Pull complete
afa7f7d582de: Pull complete
d597c14cfeb9: Download complete
Digest: sha256:6a06111c3b0a8600feadb270aec771dc239bf407b25625f93f44ab00e11f4d3c
Status: Downloaded newer image for ubuntu:latest
root@534f2eec44fa:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@534f2eec44fa:/# echo "hello from container"
hello from container
root@534f2eec44fa:/# cat /etc/os-release
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04.1 LTS (Resolute Raccoon)"
VERSION_CODENAME=resolute
ID=ubuntu
ID_LIKE=debian
...
root@534f2eec44fa:/# exit
```

> **관찰**: 호스트는 macOS인데 컨테이너 내부는 Ubuntu 리눅스입니다. 컨테이너가 호스트와 분리된 격리 환경에서 동작함을 확인했습니다.
> (참고: 위 출력은 여러 줄을 한 번에 붙여 넣어 실행한 뒤 보기 좋게 정리한 것입니다. TODO: 가능하면 한 줄씩 입력한 캡처로 교체)

**종료/유지 비교 (attach / exec)**

```bash
# 실험 A: run -it 후 exit
$ docker run -it --name exp-a ubuntu bash
root@...:/# exit
$ docker ps -a
TODO

# 실험 B: exec 로 들어갔다 나오기
$ docker run -d --name exp-b ubuntu sleep infinity
$ docker exec -it exp-b bash
root@...:/# exit
$ docker ps
TODO

# 실험 C: attach 후 exit
$ docker run -dit --name exp-c ubuntu bash
$ docker attach exp-c
root@...:/# exit
$ docker ps -a
TODO
```

| 방식 | 붙는 대상 | exit 후 컨테이너 |
|---|---|---|
| `run -it` | 메인 프로세스 | 종료 (TODO: 실제 결과로 확인) |
| `attach` | 메인 프로세스 | 종료 (TODO) |
| `exec -it` | 새로 만든 별도 프로세스 | 유지 (TODO) |

### 5-6. Dockerfile 기반 커스텀 이미지

**선택한 방식**: (A) 웹 서버 베이스 이미지 활용 — `nginx:alpine` + 정적 콘텐츠 교체

**프로젝트 구조**
```
custom-web/
├── Dockerfile
├── README.md
└── site/
    └── index.html
```

**site/index.html**
```html
<!DOCTYPE html>
<html lang="ko">
<head><meta charset="UTF-8"><title>My Custom Web</title></head>
<body>
  <h1>Hello from my custom nginx image!</h1>
</body>
</html>
```

**Dockerfile**
```dockerfile
FROM nginx:alpine
LABEL org.opencontainers.image.title="my-custom-nginx"
ENV APP_ENV=dev
COPY site/ /usr/share/nginx/html/
```

| 커스텀 포인트 | 목적 |
|---|---|
| `FROM nginx:alpine` | 가볍고 검증된 웹 서버 베이스 이미지를 재사용 |
| `LABEL` | 이미지 메타데이터(이름)를 남겨 식별 가능하게 함 |
| `ENV APP_ENV=dev` | 실행 모드를 코드와 분리된 환경변수로 관리 |
| `COPY site/ ...` | 기본 페이지 대신 내가 만든 정적 콘텐츠를 이미지에 포함 |

**빌드/실행**
```bash
$ docker build -t my-web:1.0 .
TODO
$ docker images my-web
TODO
```

### 5-7. 포트 매핑

```bash
$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
$ curl http://localhost:8080
TODO

$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0
$ curl http://localhost:8081
TODO

$ docker ps
TODO
```

**브라우저 접속 증거** (주소창 포함)

TODO: `docs/images/port-8080.png`, `docs/images/port-8081.png` 첨부

```markdown
![8080 접속](docs/images/port-8080.png)
![8081 접속](docs/images/port-8081.png)
```

### 5-8. 바인드 마운트

```bash
$ docker rm -f my-web-8080 my-web-8081
$ docker run -d -p 8082:80 --name my-web-bind \
    -v "$(pwd)/site":/usr/share/nginx/html my-web:1.0
```

**변경 전**
```bash
$ curl http://localhost:8082
TODO
```

**호스트에서 파일 수정**
```bash
$ sed -i '' 's/Hello from my custom nginx image!/Bind mount works!/' site/index.html
```
(macOS의 `sed -i ''` 문법입니다. 리눅스에서는 `sed -i`)

**변경 후 (컨테이너 재시작 없이)**
```bash
$ curl http://localhost:8082
TODO
```

### 5-9. Docker 볼륨 영속성

```bash
$ docker volume create mydata
$ docker volume ls
TODO
$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test bash -c "echo hi > /data/hello.txt && cat /data/hello.txt"
hi
$ docker rm -f vol-test            # 컨테이너 삭제
$ docker ps -a | grep vol-test     # 없음 확인
TODO

$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test2 bash -c "cat /data/hello.txt"
TODO (hi 가 나와야 함)
$ docker volume inspect mydata
TODO
```

### 5-10. Git 설정 및 GitHub 연동

```bash
$ git config --global user.name "<이름>"
$ git config --global user.email "<이메일>"
$ git config --global init.defaultBranch main
$ git config --list
TODO (이메일 등 공개가 부담스러우면 마스킹)
```

**VSCode GitHub 연동 증거**

TODO: 로그인 완료 화면 / 저장소 연결 / push 결과 캡처 (토큰·인증코드 노출 금지)

```bash
$ git remote -v
TODO
$ git push -u origin main
TODO
```

---

## 6. 개념 정리

### 절대 경로와 상대 경로
- **절대 경로**: 루트(`/`)부터 시작하는 전체 경로. 어디서 실행해도 같은 위치를 가리킨다. 예: `/Users/<user>/codyssey/practice`
- **상대 경로**: 현재 위치 기준. 예: 현재 위치가 `~/codyssey`일 때 `practice/a.txt`, 상위 폴더는 `..`, 현재 폴더는 `.`

### 파일 권한 (r/w/x, 755, 644)
- `r`=읽기(4), `w`=쓰기(2), `x`=실행(1). 소유자 / 그룹 / 기타 순으로 세 자리로 표기한다.
- `755` = 소유자 `rwx`(7), 그룹 `r-x`(5), 기타 `r-x`(5) → 실행 파일, 디렉토리에 흔히 사용
- `644` = 소유자 `rw-`(6), 그룹 `r--`(4), 기타 `r--`(4) → 일반 파일에 흔히 사용
- 디렉토리에서 `x`는 "그 안으로 들어갈 수 있는 권한"이다.

### 포트 매핑이 필요한 이유
컨테이너는 자체 네트워크 공간에서 격리되어 있어 호스트에서 컨테이너 내부 포트에 바로 접근할 수 없다. `-p 호스트포트:컨테이너포트`로 호스트 포트를 컨테이너 포트에 연결해야 브라우저/curl로 접속할 수 있다. 같은 이미지를 포트만 바꿔 여러 개 띄울 수 있는 이유도 이것이다.

### Docker 볼륨
컨테이너의 파일 시스템은 컨테이너가 삭제되면 함께 사라진다. 볼륨은 Docker가 관리하는 별도 저장소로, 컨테이너 생명주기와 분리되어 데이터가 유지된다. 바인드 마운트가 "호스트의 특정 경로를 연결"하는 것이라면, 볼륨은 "Docker가 관리하는 저장 공간"이다.

### 이미지와 컨테이너
이미지는 변하지 않는 실행 템플릿(읽기 전용 레이어)이고, 컨테이너는 그 이미지로 만든 실행 인스턴스이다. 같은 이미지에서 여러 컨테이너를 만들 수 있어 "내 컴퓨터에서만 돌아가는" 문제를 줄인다.

### Git과 GitHub
- **Git**: 내 컴퓨터에서 변경 이력을 관리하는 분산 버전 관리 도구(로컬).
- **GitHub**: Git 저장소를 원격에 호스팅하고 협업(PR, 이슈, 공유)을 제공하는 플랫폼.

---

## 7. 트러블슈팅 (2건 이상)

> 실제로 겪은 문제로 채우세요. 아래는 작성 형식 예시입니다. 직접 겪지 않은 내용을 적지 마세요.

### 7-1. TODO: 제목
- **문제**: TODO (실제 오류 메시지)
- **원인 가설**: TODO
- **확인**: TODO (확인에 쓴 명령/결과)
- **해결/대안**: TODO

### 7-2. TODO: 제목
- **문제**: TODO
- **원인 가설**: TODO
- **확인**: TODO
- **해결/대안**: TODO

**자주 만나는 후보 (실제로 겪었다면 사용)**
- `Cannot connect to the Docker daemon` → OrbStack 미실행 → OrbStack 앱 실행 후 `docker info` 재확인
- `port is already allocated` → 해당 호스트 포트 사용 중 → `docker ps`로 확인 후 포트 변경 또는 기존 컨테이너 삭제
- `The container name ... is already in use` → 같은 이름의 컨테이너가 남아 있음 → `docker rm -f 이름`
- 바인드 마운트 후 빈 페이지/403 → 마운트 경로/파일 권한 확인

---

## 8. 보안 및 개인정보

- 토큰, 비밀번호, 개인키, 인증 코드는 로그/스크린샷에 포함하지 않았습니다.
- 경로의 사용자명, 이메일 등은 필요 시 `<user>`, `<email>`로 마스킹했습니다.

---

## 9. 재현 방법

```bash
git clone <저장소 URL>
cd <저장소명>
docker build -t my-web:1.0 .
docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
curl http://localhost:8080
```

- 사전 준비: OrbStack 설치 및 실행 (또는 Docker 엔진), Git
- 주의: 호스트 포트 8080/8081/8082가 비어 있어야 합니다. 사용 중이면 `-p` 앞의 포트를 바꾸세요.

---

## 10. (보너스) 선택 과제

- [ ] Docker Compose 단일 서비스
- [ ] Compose 멀티 컨테이너 + 네트워크 통신
- [ ] Compose 운영 명령 (`up`, `down`, `ps`, `logs`)
- [ ] 환경변수로 포트/모드 변경
- [ ] GitHub SSH 키 설정

TODO: 진행한 항목만 로그와 함께 추가
