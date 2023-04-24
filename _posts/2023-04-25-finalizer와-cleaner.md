---
layout: post
title: finalizer와 cleaner
date: 2023-04-25 05:49 +0900
---

### 객체 소멸자

- C++의 파괴자와는 다름
  - 자바에서는 가비지 컬렉터의 역할
  - 비메모리 자원은 [try-with-resource와 try-finally](https://www.notion.so/09-try-finally-try-with-resources-e271cc5d610b48a09078f919dc8e01ef) 사용
- 즉시 수행된다는 보장 없음
- 사용하지 않는 방법이 가장 좋음
- 상태를 영구적으로 수정하는 작업에서는 절대 의존해서는 안 됨
- finalizer 실행 보장 메서드는 심각한 결함 내재
- 내부에서 발생한 예외가 무시됨
- 처리할 작업이 남아도 종료
  - 훼손된 객체 유발 가능성
- 심각한 성능 문제 동반
- finalizer 공격 노출 가능성
  - final 클래스는 이 공격에서 안전
  - final이 아닌 클래스를 방어하려면 아무 일도 하지 않는 finalize 메서드를 만들고 final로 선언
- finalizer
  - 예측 불가, 위험, 일반적으로 불필요
  - 오동작, 낮은 성능, 이식성 문제 유발
  - 자바 9에서 deprecated로 지정
- cleaner
  - finalizer보다는 나음
  - 자신을 수행할 스레드를 제어 가능
  - 여전히 예측 불가, 느림, 불필요
  - 사용할지 말지는 내부 구현 방식에 관한 문제
  - 안전망으로 제한적으로 사용
  - 클래스의 public API에 나타나지 않음
  - 구현
    - 코드
      ```java
      // An autocloseable class using a cleaner as a safety net (Page 32)
      public class Room implements AutoCloseable {
          private static final Cleaner cleaner = Cleaner.create();

          // Resource that requires cleaning. Must not refer to Room!
          private static class State implements Runnable {
              int numJunkPiles; // Number of junk piles in this room

              State(int numJunkPiles) {
                  this.numJunkPiles = numJunkPiles;
              }

              // Invoked by close method or cleaner
              @Override public void run() {
                  System.out.println("Cleaning room");
                  numJunkPiles = 0;
              }
          }

          // The state of this room, shared with our cleanable
          private final State state;

          // Our cleanable. Cleans the room when it’s eligible for gc
          private final Cleaner.Cleanable cleanable;

          public Room(int numJunkPiles) {
              state = new State(numJunkPiles);
              cleanable = cleaner.register(this, state);
          }

          @Override public void close() {
              cleanable.clean();
          }
      }
      ```
    - 정적 멤버 클래스(State)에 cleaner가 수거할 자원을 담음
      - State는 Runnable을 구현
      - run 메서드는 cleanable에 의해 한 번만 호출
      - cleanable 객체는 생성자(Room)에서 cleaner 객체에 인스턴스(Room과 State)를 등록할 때 얻음
      - run 메서드가 호출되는 상황
        - close 메서드를 호출하는 경우
          - Cleanable의 clean을 호출 ⇒ run 호출
        - 인스턴스(Room) 회수 시 클라이언트가 close를 호출하지 않는 경우
          - cleaner가 State 객체의 run 메서드 호출
    - State 인스턴스는 Room 인스턴스를 참조 금지
      - 순환 참조 시 가비지 컬렉터의 Room 인스턴스 회수 기회 박탈
      - [정적이 아닌 중첩 클래스는 자동으로 바깥 객체의 참조를 가지므로](https://www.notion.so/24-static-59f5e399632447da9499af33fad602e4)(람다도 해당) State를 정적으로 정의
  - 클라이언트가 모든 Room의 생성을 try-with-resources 블록으로 감싼 경우에 자동 청소 불필요
- 쓰임새
  - 자원의 소유자가 close 메서드를 호출하지 않는 것에 대비한 안전망
    - 안전망 역할이 가치가 있는지 심사숙고 필요
  - 네이티브 피어와 연결된 객체
    - 네이티브 피어
      - 일반 자바 객체가 네이티브 메서드를 통해 기능을 위임한 네이티브 객체
      - 자바 객체가 아니기에 가비지 컬렉터가 존재를 알지 못 함
      - 성능 저하를 감당할 수 있고 네이티브 피어가 심각한 자원을 가지고 있지 않을 때 적용 가능
      - 자원을 즉시 회수해야 할 때는 close 메서드 사용

### AutoCloseable

- 파일이나 스레드 등 종료해야 할 자원을 담은 객체의 클래스에서 사용
- 클라이언트에서 인스턴스 다 쓰고 나서 close 메서드 호출
- close 메서드에서는 객체가 유효하지 않음을 필드에 기록
  - 객체가 닫힌 후 호출 시 유효성 검사 후 IllegalStateException
