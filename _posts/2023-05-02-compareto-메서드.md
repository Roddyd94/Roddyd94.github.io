---
layout: post
title: compareTo 메서드
date: 2023-05-02 08:40 +0900
---

### Comparable 인터페이스

- 인스턴스의 순서가 있는 클래스에서 구현
- 모든 값 타입과 [열거 타입](https://www.notion.so/b6b9b915c66f426bb14ff29249ecae58)에서 구현
- compareTo 메서드
  - 동치성 및 순서 비교
  - 제네릭 특성
  - TreeSet, TreeMap, Collections, Arrays 등에서 활용
  - 다른 타입 사이에서 사용 시 공통 인터페이스 사용
  - 다른 객체와 비교 시
    - 작으면 음의 정수
    - 같으면 0
    - 크면 양의 정수
    - 비교 불가인 경우 ClassCasrException
  - 반사성, 대칭성, 추이성을 만족하도록 구현
  - 동치성 테스트의 결과가 equals와 같도록 구현
  - 구체 클래스에서 새 값 컴포넌트 추가 시 규약 만족 불가능
    - equals와 같이 컴포지션 사용
  - 인수 타입이 컴파일타임에 지정
  - 객체 참조 필드 비교 시 compareTo를 재귀적으로 호출
    - Comparable 미구현 필드 등은 Comparator 사용
  - 부동소수점 필드 비교 시 박싱된 타입 클래스의 compare 사용
  - **관계 연산자 사용 지양**
  - 핵심 필드부터 비교
  - Comparator 사용 시 간결하게 작성 가능
    - 성능 저하 가능성
  - 값의 차를 기준으로 하는 비교자 지양
    1. compare 메서드 사용 비교자
    2. 비교자 생성 메서드 활용 비교자
    - 1, 2 중 하나 사용 권장
