---
layout: post
title: try-with-resources
date: 2023-04-25 05:50 +0900
---

### 자원 닫기

- InputStream, OutputStream, java.sql.Connection 등에서는 close 메서드 호출 필요
- 자원 닫기는 놓치기 쉬움
- [안전망으로 finalizer를 사용하나 믿을만하지 못함](https://www.notion.so/08-finalizer-cleaner-949bc91f706447dfa84f58ac2825416c)

### try-finally

- 자원의 닫힘을 보장하는 수단
- 지저분함
- 결점이 존재
  - 기기에 물리적인 문제 발생 시 디버깅이 어려운 예외 발생
    - 두 번째 예외 때문에 첫 번째 예외가 무시됨

### try-with-resources

- AutoCloseable을 구현한 자원만 사용 가능
- 짧고 좋은 가독성, 문제 진단 용이
- 스택 추적 내역에 숨겨진 예외들도 표시
- catch 절 사용 가능
  - try 중첩 없이 다수의 예외 처리 가능
