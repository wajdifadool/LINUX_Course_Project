FROM openjdk:17

WORKDIR /app

COPY  Watermark.java .

RUN java Watermark.java

ENTRYPOINT ["java", "Watermark"]