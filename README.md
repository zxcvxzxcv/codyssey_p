# 내 컴퓨터에 개발자용 '작업실' 꾸미기

> 터미널 · Docker(OrbStack) · Git/GitHub 로 재현 가능한 개발 환경을 만들고, 모든 과정을 로그와 증거로 남긴 기술 문서입니다.

> ⚠️ **작성 가이드**: `TODO`는 아직 수행/첨부하지 않은 항목입니다. 직접 실행한 결과로 채운 뒤 이 안내 문구는 지우세요.

---

## 1. 프로젝트 개요

**미션 목표**
- 리눅스 CLI로 작업 디렉토리와 파일 권한을 다룬다.
- Docker를 설치·점검하고 컨테이너를 실행·관리한다.
- Dockerfile로 커스텀 이미지를 만들고, 포트 매핑·바인드 마운트·볼륨으로 접속, 변경 반영, 데이터 영속성을 검증한다.
- Git/GitHub를 설정하고 VSCode와 연동한다.

**서울캠퍼스 환경 참고**: 보안 정책상 `sudo` 사용이 제한되므로 Docker Desktop 대신 **OrbStack**을 사용했습니다. OrbStack 실행 시 Docker 엔진이 함께 구동되며, 터미널에서는 일반 `docker` 명령을 그대로 사용합니다.

**저장소**: https://github.com/zxcvxzxcv/codyssey_p

---

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| OS | macOS (Apple Silicon, aarch64) |
| Shell / Terminal | zsh / VSCode 통합 터미널 |
| Docker | 29.8.2 (build 7fc2dff), Context: `orbstack` |
| Docker Compose | v5.5.0 |
| Docker Buildx | v0.37.2 |
| Git | 2.54.0 (Apple Git-157) |
| 에디터 | VSCode |

```bash
$ docker --version
Docker version 29.8.2, build 7fc2dff

$ git --version
git version 2.54.0 (Apple Git-157)
```

---

## 3. 수행 항목 체크리스트

- [x] 터미널 기본 조작 (위치/목록/이동/생성/복사/이동·이름변경/삭제/내용 확인)
- [x] 권한 변경 실습 (파일 1개 + 디렉토리 1개)
- [x] Docker 설치/점검 (`docker --version`, `docker info`)
- [x] 이미지/컨테이너 기본 운영 (`docker build`, `ps`, `logs`, `stats`, `stop`, `rm`)
- [x] `docker images`, `docker ps -a` 출력 기록
- [x] `hello-world` 실행
- [x] `ubuntu` 컨테이너 실행 및 내부 명령 수행
- [x] 컨테이너 종료/유지 (`run -it` / `attach` / `exec`) 관찰
- [x] Dockerfile 작성 및 커스텀 이미지 빌드/실행 (`my-web:1.0`)
- [x] 포트 매핑 접속 (8080:80)
- [x] 포트 매핑 접속 2회째 (8081:80)
- [x] 바인드 마운트 변경 반영
- [x] Docker 볼륨 영속성 (named volume)
- [x] Git 사용자 정보/기본 브랜치 설정
- [x] GitHub 저장소 연동 및 push
- [ ] VSCode GitHub 로그인/연동 증거 캡처
- [ ] (보너스) Compose / 환경변수 / SSH 키

---

## 4. 검증 방법 요약

| 항목 | 사용한 명령 | 확인한 것 | 결과 위치 |
|---|---|---|---|
| Docker 설치 | `docker --version` | 버전 출력 | [5-3](#5-3-docker-설치-및-점검) |
| 데몬 동작 | `docker info` | Server 항목 정상 출력 | [5-3](#5-3-docker-설치-및-점검) |
| 컨테이너 실행 | `docker run hello-world`, `docker run -it ubuntu bash` | 실행 성공, 내부 진입 | [5-5](#5-5-컨테이너-실행-실습) |
| 이미지 빌드 | `docker build -t my-web:1.0 .` | 빌드 성공 | [5-6](#5-6-dockerfile-기반-커스텀-이미지) |
| 포트 매핑 | `docker run -p 8080:80`, 브라우저 접속 | 호스트 포트로 응답 수신 | [5-7](#5-7-포트-매핑) |
| 운영 명령 | `docker ps / logs / stats / stop / rm` | 상태, 로그, 리소스 확인 | [5-4](#5-4-이미지컨테이너-기본-운영) |
| 바인드 마운트 | `-v $(pwd)/site:/usr/share/nginx/html` | 호스트 파일 수정이 즉시 반영 | [5-8](#5-8-바인드-마운트) |
| 볼륨 영속성 | `docker volume create`, 컨테이너 삭제 후 재연결 | 데이터 유지 | [5-9](#5-9-docker-볼륨-영속성) |
| Git 설정 | `git config --list` | 사용자 정보/기본 브랜치 | [5-10](#5-10-git-설정-및-github-연동) |
| GitHub push | `git push -u origin main` | 원격 저장소에 파일 업로드 | [5-10](#5-10-git-설정-및-github-연동) |

---

## 5. 수행 로그

### 5-1. 터미널 기본 조작

```bash
$ mkdir -p ~/codyssey/practice && cd ~/codyssey/practice
$ pwd
/Users/<user>/codyssey/practice
$ ls -la
total 0
drwxr-xr-x@ 2 <user>  staff   64 Nov  2 21:24 .
drwxr-xr-x  5 <user>  staff  160 Nov  2 21:24 ..
$ touch a.txt
$ echo "hello" > b.txt
$ cat b.txt
hello
$ cp b.txt c.txt
$ mv c.txt d.txt                 # 이름 변경
$ mkdir sub && mv d.txt sub/     # 이동
$ ls -la . sub
.:
total 8
drwxr-xr-x@ 5 <user>  staff  160 Nov  2 21:25 .
drwxr-xr-x  5 <user>  staff  160 Nov  2 21:24 ..
-rw-r--r--@ 1 <user>  staff    0 Nov  2 21:25 a.txt
-rw-r--r--@ 1 <user>  staff    6 Nov  2 21:25 b.txt
drwxr-xr-x@ 3 <user>  staff   96 Nov  2 21:25 sub

sub:
total 8
drwxr-xr-x@ 3 <user>  staff   96 Nov  2 21:25 .
drwxr-xr-x@ 5 <user>  staff  160 Nov  2 21:25 ..
-rw-r--r--@ 1 <user>  staff    6 Nov  2 21:25 d.txt
$ rm a.txt
$ rm -r sub
$ ls -la
total 8
drwxr-xr-x@ 3 <user>  staff   96 Nov  2 21:25 .
drwxr-xr-x  5 <user>  staff  160 Nov  2 21:24 ..
-rw-r--r--@ 1 <user>  staff    6 Nov  2 21:25 b.txt
```

> `@`는 macOS의 확장 속성 표시이며 권한 해석에는 영향이 없다. 연습은 Git 저장소(`custom-web`) 밖의 `~/codyssey/practice`에서 수행했다.

### 5-2. 권한 실습

**파일**
```bash
$ touch perm.txt
$ ls -l perm.txt          # 변경 전
-rw-r--r--@ 1 <user>  staff  0 Nov  2 21:26 perm.txt
$ chmod 600 perm.txt
$ ls -l perm.txt          # 변경 후
-rw-------@ 1 <user>  staff  0 Nov  2 21:26 perm.txt
```

**디렉토리**
```bash
$ mkdir permdir
$ ls -ld permdir          # 변경 전
drwxr-xr-x@ 2 <user>  staff  64 Nov  2 21:26 permdir
$ chmod 644 permdir
$ ls -ld permdir          # x 권한 제거 후
drw-r--r--@ 2 <user>  staff  64 Nov  2 21:26 permdir
$ cd permdir
cd: permission denied: permdir
$ chmod 755 permdir
$ ls -ld permdir          # 복구 후
drwxr-xr-x@ 2 <user>  staff  64 Nov  2 21:26 permdir
$ cd permdir && cd ..
```

**관찰**
- 파일: `644`(rw-r--r--)에서 `600`(rw-------)으로 바꾸자 그룹/기타 사용자의 읽기 권한이 사라졌다.
- 디렉토리: `x`(실행) 권한을 빼자(`644`) `cd`가 `permission denied`로 막혔다. `755`로 되돌리니 다시 들어갈 수 있었다. 디렉토리에서 `x`는 "안으로 들어갈 수 있는 권한"이다.

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

### 5-4. 이미지/컨테이너 기본 운영

```bash
$ docker images
IMAGE                ID             DISK USAGE   CONTENT SIZE   EXTRA
hello-world:latest   c567b231f656       18.5kB         10.3kB    U
my-web:1.0           de98bc82200c        258MB         62.2MB
ubuntu:latest        6a06111c3b0a        179MB         44.9MB    U

$ docker ps
CONTAINER ID   IMAGE        STATUS         PORTS                  NAMES
f20ebc13d92f   my-web:1.0   Up 8 minutes   0.0.0.0:8080->80/tcp   web-test

$ docker logs web-test
TODO (스크린샷 기준 핵심: nginx 시작 메시지, "GET / HTTP/1.1" 200, favicon.ico 404)

$ docker stats web-test
TODO (스크린샷 기준: CPU 0.00%, MEM 약 9MB / 7.8GB, PIDS 11)

$ docker stop web-test
web-test
$ docker rm web-test
web-test
$ docker ps
TODO (비어 있음)
$ docker ps -a
TODO
```

**로그 해석**
- `GET / HTTP/1.1 200`: 브라우저의 접속 요청이 성공했다는 기록
- `favicon.ico ... 404`: 브라우저가 자동으로 아이콘을 요청했지만 우리 페이지에 아이콘 파일이 없어서 생긴 것으로, 기능에는 영향이 없다.

> TODO: 위 출력은 스크린샷 값을 요약한 것입니다. 실제 터미널 출력을 복사해서 교체하세요.

### 5-5. 컨테이너 실행 실습

**hello-world**
```bash
$ docker run hello-world

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm64v8)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
...
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED                  STATUS                              PORTS     NAMES
4edbda0abe3d   hello-world   "/hello"   Less than a second ago   Exited (0) Less than a second ago             unruffled_nash
534f2eec44fa   ubuntu        "bash"     35 minutes ago           Exited (0) 34 minutes ago                     ubuntu-test
9b5951d6992d   hello-world   "/hello"   35 minutes ago           Exited (0) 35 minutes ago                     goofy_varahamihira
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
...
root@534f2eec44fa:/# exit
```

> **관찰**: 호스트는 macOS인데 컨테이너 내부는 Ubuntu 리눅스다. 컨테이너가 호스트와 분리된 격리 환경에서 동작함을 확인했다.

**종료/유지 비교 (run -it / exec / attach)**

```bash
# 실험 A: run -it 후 exit
$ docker run -it --name exp-a ubuntu bash
root@6b58a9ac6428:/# exit

# 실험 B: exec 로 들어갔다 나오기
$ docker run -d --name exp-b ubuntu sleep infinity
$ docker exec -it exp-b bash
root@70b96af700d2:/# exit
$ docker ps
CONTAINER ID   IMAGE     COMMAND            CREATED          STATUS          PORTS     NAMES
70b96af700d2   ubuntu    "sleep infinity"   18 seconds ago   Up 17 seconds             exp-b

# 실험 C: attach 후 exit
$ docker run -dit --name exp-c ubuntu bash
$ docker attach exp-c
root@7f00c37ad9eb:/# exit
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND            CREATED          STATUS                          PORTS     NAMES
7f00c37ad9eb   ubuntu        "bash"             11 seconds ago   Exited (0) 5 seconds ago                  exp-c
70b96af700d2   ubuntu        "sleep infinity"   46 seconds ago   Up 45 seconds                             exp-b
6b58a9ac6428   ubuntu        "bash"             2 minutes ago    Exited (0) About a minute ago             exp-a
...
```

| 방식 | 붙는 대상 | exit 후 컨테이너 | 근거 |
|---|---|---|---|
| `run -it` | 메인 프로세스(bash) | **종료** | `exp-a`, `ubuntu-test` Exited (0) |
| `exec -it` | 새로 만든 별도 프로세스 | **유지** | `exp-b` Up |
| `attach` | 메인 프로세스(bash) | **종료** | `exp-c` Exited (0) |

**정리**: 컨테이너는 메인 프로세스가 살아 있는 동안만 실행된다. `run -it`과 `attach`는 메인 프로세스에 직접 붙으므로 `exit`하면 컨테이너도 종료된다. `exec`는 이미 실행 중인 컨테이너 안에 별도 프로세스를 하나 더 띄우는 것이라, 나와도 메인 프로세스(`sleep infinity`)가 남아 컨테이너가 유지된다.

### 5-6. Dockerfile 기반 커스텀 이미지

**선택한 방식**: (A) 웹 서버 베이스 이미지 활용 — `nginx:latest` + 정적 콘텐츠 교체

**프로젝트 구조**
```
custom-web/
├── Dockerfile
├── .gitignore
├── README.md
└── site/
    └── index.html
```

**Dockerfile**
```dockerfile
# 1. nginx 공식 이미지를 베이스로 사용
FROM nginx:latest

# 2. 내가 만든 index.html을 nginx 기본 웹 폴더로 복사
COPY site/ /usr/share/nginx/html/
```

| 커스텀 포인트 | 목적 |
|---|---|
| `FROM nginx:latest` | 이미 검증된 웹 서버 이미지를 재사용해 바닥부터 만들지 않는다 |
| `COPY site/ /usr/share/nginx/html/` | nginx 기본 페이지 대신 내가 만든 정적 콘텐츠를 이미지에 포함한다 |

**빌드 결과 (핵심)**
```bash
$ docker build -t my-web:1.0 .
...
 => [1/2] FROM docker.io/library/nginx:latest
 => [2/2] COPY site/ /usr/share/nginx/html/
 => naming to docker.io/library/my-web:1.0
```
> TODO: 실제 출력 전체 또는 스크린샷으로 교체

### 5-7. 포트 매핑

```bash
$ docker run -d -p 8080:80 --name web-8080 my-web:1.0
$ docker run -d -p 8081:80 --name web-8081 my-web:1.0
$ docker ps
CONTAINER ID   IMAGE        COMMAND                  CREATED         STATUS         PORTS                                     NAMES
0e6004bfa3a8   my-web:1.0   "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   web-8081
ea59825f4b8b   my-web:1.0   "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   web-8080
$ curl http://localhost:8080
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>My Custom Nginx</title>
</head>
<body>
  <h1>Hello from my custom image!</h1>
  <p>포트 매핑 테스트 페이지입니다.</p>
</body>
</html>
$ curl http://localhost:8081
(위와 동일한 응답)
```

같은 이미지(`my-web:1.0`)로 컨테이너 2개를 서로 다른 호스트 포트(8080, 8081)에 연결했고, 둘 다 컨테이너의 80번 포트로 전달되어 같은 페이지가 응답했다.

**브라우저 접속 증거** (주소창 포함)

![8080 접속](docs/images/port-8080.png)
![8081 접속](docs/images/port-8081.png)

> TODO: `port-8080.png`(주소창 포함) 추가. `port-8081.png`는 캡처 완료.

### 5-8. 바인드 마운트

```bash
$ docker run -d -p 8080:80 \
    -v $(pwd)/site:/usr/share/nginx/html \
    --name web-vol my-web:1.0
$ docker ps
TODO
```

**변경 전**: 브라우저(`localhost:8080`)에 "🐳 Volume 실습 중!" 표시
**호스트에서 `site/index.html` 수정** (VSCode, 컨테이너 재시작 없음)
**변경 후**: 브라우저를 새로고침하자 수정한 제목과 추가한 문구("✅ 수정이 바로 반영됐나요?")가 바로 반영됨

TODO: 변경 전/후 브라우저 캡처 첨부

### 5-9. Docker 볼륨 영속성

> 5-8은 호스트 폴더를 연결하는 **바인드 마운트**이고, 아래는 Docker가 관리하는 **named volume** 검증이다.

```bash
$ docker volume create mydata
mydata
$ docker volume ls
DRIVER    VOLUME NAME
local     mydata
$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
5e6eecd46a7dcd008050b99c8cf6e8780d04fcf732e4eb7d1ced1e0b522974c8
$ docker exec vol-test bash -c "echo hi > /data/hello.txt && cat /data/hello.txt"
hi
$ docker rm -f vol-test            # 컨테이너 삭제
vol-test
$ docker ps -a                     # vol-test 가 목록에 없음
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                      PORTS                                     NAMES
0e6004bfa3a8   my-web:1.0    "/docker-entrypoint.…"   4 minutes ago    Up 4 minutes                0.0.0.0:8081->80/tcp, [::]:8081->80/tcp   web-8081
ea59825f4b8b   my-web:1.0    "/docker-entrypoint.…"   4 minutes ago    Up 4 minutes                0.0.0.0:8080->80/tcp, [::]:8080->80/tcp   web-8080
4edbda0abe3d   hello-world   "/hello"                 7 minutes ago    Exited (0) 7 minutes ago                                              unruffled_nash
534f2eec44fa   ubuntu        "bash"                   43 minutes ago   Exited (0) 42 minutes ago                                             ubuntu-test
9b5951d6992d   hello-world   "/hello"                 43 minutes ago   Exited (0) 43 minutes ago                                             goofy_varahamihira

$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
260c31955d134878be7d403260f6b3edae0529d386cd3bb4ab84b053c9293393
$ docker exec vol-test2 bash -c "cat /data/hello.txt"
hi
$ docker volume inspect mydata
[
    {
        "CreatedAt": "2026-11-02T21:34:32+09:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/mydata/_data",
        "Name": "mydata",
        "Options": null,
        "Scope": "local"
    }
]
```

**결론**: 컨테이너(`vol-test`)를 삭제한 뒤 새 컨테이너(`vol-test2`)에 같은 볼륨(`mydata`)을 연결하자 이전에 쓴 `hi`가 그대로 남아 있었다. 데이터가 컨테이너 생명주기와 분리되어 유지됨을 확인했다.

### 5-10. Git 설정 및 GitHub 연동

```bash
$ git config --global user.name "<GitHub 사용자명>"
$ git config --global user.email "<이메일 마스킹>"
$ git config --global init.defaultBranch main
$ git config --list
TODO (user.email 등은 마스킹, init.defaultbranch=main 확인)
```

```bash
$ git init
Initialized empty Git repository in .../codyssey/custom-web/.git/
$ git add .
$ echo ".DS_Store" > .gitignore
$ git rm --cached -f .DS_Store
$ git commit -m "first commit: add Dockerfile, index.html, gitignore"
$ git log --oneline
f2fef36 first commit: add Dockerfile, index.html, gitignore
$ git remote add origin https://github.com/zxcvxzxcv/codyssey_p.git
$ git remote -v
TODO
$ git push -u origin main
TODO (스크린샷 기준: 6 objects, main -> main, 추적 설정 완료)
```

**연동 증거**
- GitHub 저장소 화면 캡처 (Dockerfile, site/index.html, .gitignore 업로드 확인): TODO
- VSCode GitHub 로그인/저장소 연동 캡처: TODO (토큰, 인증 코드 노출 금지)

---

## 6. 개념 정리

### 절대 경로와 상대 경로
- **절대 경로**: 루트(`/`)부터 시작하는 전체 경로. 어디서 실행해도 같은 위치를 가리킨다. 예: `/Users/<user>/codyssey/custom-web`
- **상대 경로**: 현재 위치 기준. 예: 현재 위치가 `~/codyssey`일 때 `custom-web/site/index.html`, 상위 폴더는 `..`, 현재 폴더는 `.`

### 파일 권한 (r/w/x, 755, 644)
- `r`=읽기(4), `w`=쓰기(2), `x`=실행(1). 소유자 / 그룹 / 기타 순으로 세 자리로 표기한다.
- `755` = 소유자 `rwx`(7), 그룹 `r-x`(5), 기타 `r-x`(5) → 실행 파일, 디렉토리에 흔히 사용
- `644` = 소유자 `rw-`(6), 그룹 `r--`(4), 기타 `r--`(4) → 일반 파일에 흔히 사용
- 디렉토리에서 `x`는 "그 안으로 들어갈 수 있는 권한"이다.

### 포트 매핑이 필요한 이유
컨테이너는 자체 네트워크 공간에서 격리되어 있어 호스트에서 컨테이너 내부 포트에 바로 접근할 수 없다. `-p 호스트포트:컨테이너포트`로 호스트 포트를 컨테이너 포트에 연결해야 브라우저/curl로 접속할 수 있다. nginx는 컨테이너 안에서 80번을 쓰므로 `8080:80`으로 연결했다. 같은 이미지를 포트만 바꿔 여러 개 띄울 수 있는 이유도 이것이다.

### Docker 볼륨
컨테이너의 파일 시스템은 컨테이너가 삭제되면 함께 사라진다. 볼륨은 Docker가 관리하는 별도 저장소로, 컨테이너 생명주기와 분리되어 데이터가 유지된다. 바인드 마운트가 "호스트의 특정 경로를 연결"하는 것이라면, 볼륨은 "Docker가 관리하는 저장 공간"이다.

### 이미지와 컨테이너
이미지는 변하지 않는 실행 템플릿(읽기 전용 레이어)이고, 컨테이너는 그 이미지로 만든 실행 인스턴스이다. 같은 이미지에서 여러 컨테이너를 만들 수 있어 "내 컴퓨터에서만 돌아가는" 문제를 줄인다.

### Git과 GitHub
- **Git**: 내 컴퓨터에서 변경 이력을 관리하는 분산 버전 관리 도구(로컬).
- **GitHub**: Git 저장소를 원격에 호스팅하고 협업(PR, 이슈, 공유)을 제공하는 플랫폼.

---

## 7. 트러블슈팅

### 7-1. OrbStack 설치 후 `command not found: docker`
- **문제**: OrbStack 앱을 설치/실행했는데 터미널에서 `zsh: command not found: docker`
- **원인 가설**: 이미 열려 있던 터미널이 설치로 추가된 `docker` 명령 경로(PATH)를 인식하지 못함
- **확인**: 터미널을 완전히 종료(⌘+Q)했다가 다시 열고 `docker --version` 실행
- **해결**: 새 터미널에서 버전이 정상 출력되었고 `docker info`도 성공

### 7-2. 터미널에 HTML을 붙여넣었을 때 `zsh: event not found: DOCTYPE`
- **문제**: `<!DOCTYPE html>`을 터미널에 그대로 붙여넣자 `zsh: event not found: DOCTYPE`
- **원인 가설**: zsh에서 `!`는 히스토리 확장 문자라서 명령으로 해석됨. HTML은 명령이 아니라 파일 내용이다.
- **확인**: HTML은 터미널이 아니라 에디터로 저장해야 한다는 점을 확인
- **해결**: VSCode에서 `site/index.html` 파일을 만들어 저장

### 7-3. 폴더가 `site/site`로 중첩됨
- **문제**: VSCode 탐색기에서 경로가 `site › site › index.html`로 표시됨
- **원인 가설**: 이미 `site`를 만든 상태에서 새 폴더를 또 `site`로 만듦. 이대로면 `COPY site/ ...`가 의도와 다른 경로를 복사한다.
- **확인**: `ls -R site`로 구조 확인
- **해결**
  ```bash
  mv site/site/index.html site/index.html
  rmdir site/site
  ```

### 7-4. `.DS_Store`가 스테이징에 올라가고 `git rm --cached`가 실패
- **문제**: `git status`에 macOS 시스템 파일 `.DS_Store`가 올라가 있었고, `git rm --cached .DS_Store`가 `staged content different from both the file and the HEAD` 오류로 실패
- **원인 가설**: 스테이징된 내용과 현재 파일/HEAD가 모두 달라서 Git이 안전을 위해 거부함
- **확인**: 오류 메시지의 `use -f to force removal` 안내
- **해결**
  ```bash
  echo ".DS_Store" > .gitignore
  git rm --cached -f .DS_Store
  git status
  ```
  `-f`는 Git 추적에서만 제외하고 실제 파일은 삭제하지 않는다. 이후 `.gitignore`로 제외됨.

### 7-5. `git config --list` 이후 입력이 안 됨
- **문제**: 출력 후 프롬프트로 돌아오지 않고 입력이 되지 않음
- **원인 가설**: 출력이 길어서 페이저(less 계열) 화면으로 열려 있음
- **해결**: `q`를 눌러 빠져나옴

---

## 8. 보안 및 개인정보

- 토큰, 비밀번호, 개인키, 인증 코드는 로그/스크린샷에 포함하지 않았습니다.
- `git config --list` 등 이메일이 보이는 캡처는 마스킹했습니다. (TODO: 캡처를 올리기 전에 반드시 확인)
- 경로의 사용자명은 필요 시 `<user>`로 마스킹했습니다.

---

## 9. 재현 방법

```bash
git clone https://github.com/zxcvxzxcv/codyssey_p.git
cd codyssey_p
docker build -t my-web:1.0 .
docker run -d -p 8080:80 --name web-test my-web:1.0
curl http://localhost:8080
```

- 사전 준비: OrbStack 설치 및 실행(또는 Docker 엔진), Git
- 주의: 호스트 포트 8080이 비어 있어야 합니다. 사용 중이면 `-p` 앞의 포트를 바꾸세요.
- 바인드 마운트 검증 시 현재 폴더(`$(pwd)`)에 `site/`가 있어야 합니다.

---

## 10. (보너스) 선택 과제

- [ ] Docker Compose 단일 서비스
- [ ] Compose 멀티 컨테이너 + 네트워크 통신
- [ ] Compose 운영 명령 (`up`, `down`, `ps`, `logs`)
- [ ] 환경변수로 포트/모드 변경
- [ ] GitHub SSH 키 설정

TODO: 진행한 항목만 로그와 함께 추가
