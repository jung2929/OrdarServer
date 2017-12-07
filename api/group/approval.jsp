<%@ include file="../config.jsp"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="com.google.gson.*" %>

<%
	if (request.getMethod().equals("POST")){
		out.println("POST");
	} else {
		out.println("There is no method");
	}
%>