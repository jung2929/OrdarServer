<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import = "java.sql.*" %>
<%
Connection mConn = null;
try{
	// 사용하려는 데이터베이스명을 포함한 URL 기술
	String url = "jdbc:mysql://*:*/*";
	// 사용자 계정
	String id = "*";
  // 사용자 계정의 패스워드
	String pw = "*";
	// 데이터베이스와 연동하기 위해 DriverManager에 등록한다.
	Class.forName("com.mysql.jdbc.Driver");
	// DriverManager 객체로부터 Connection 객체를 얻어온다.
	mConn=DriverManager.getConnection(url,id,pw);
	mConn.setAutoCommit(false);
	//out.println("연결되었습니다.");
}catch(Exception e){
             // 예외가 발생하면 예외 상황을 처리한다.
	e.printStackTrace();
	out.println(e);
}
%>
