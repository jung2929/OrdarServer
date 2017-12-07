<%@ include file="../config.jsp"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="ordarserver.OrderInfoRepayData" %>
<%@ page import="ordarserver.OrderInfoDetailData" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="java.io.BufferedReader" %>

<%
	if (request.getMethod().equals("GET")){
		JSONObject res = new JSONObject();
		
		String selectOrderInfoRepaySQL = "SELECT ORDER_DATE, " +
				"ORDER_SEQ, " +
				"ORDER_DATE + 7 AS DUE_DATE, " + 
				"STR_TO_DATE(ORDER_DATE + 7, '%Y%m%d') - CURRENT_DATE AS D_DAY " +
				"FROM ORDER_INFO " +
				"WHERE USER_ID = ? " +
				"AND ORDER_STATUS = '002' " +
				"ORDER BY ORDER_DATE DESC, ORDER_SEQ DESC";
		PreparedStatement pstmtParent = mConn.prepareStatement(selectOrderInfoRepaySQL);
		pstmtParent.setString(1, "root");
		ResultSet rsParent = pstmtParent.executeQuery();
		
		ArrayList<OrderInfoRepayData> orderInfoRepayArrayList = new ArrayList<>();
		
		while(rsParent.next()){
			ArrayList<OrderInfoDetailData> orderInfoDetailArrayList = new ArrayList<>();
			OrderInfoRepayData orderInfoRepayData = new OrderInfoRepayData();
			orderInfoRepayData.setORDER_DATE(rsParent.getString("ORDER_DATE"));
			orderInfoRepayData.setORDER_SEQ(rsParent.getInt("ORDER_SEQ"));
			orderInfoRepayData.setDUE_DATE(rsParent.getString("DUE_DATE"));
			orderInfoRepayData.setD_DAY(rsParent.getInt("D_DAY"));
			
			String selectOrderInfoDetailSQL = "SELECT PRODUCT_CODE, ORIGIN_PRICE AS ORDAR_PRICE, PRODUCT_QTY, '' AS PRODUCT_IMG " +
					"FROM ORDER_INFO_DETAIL " +
					"WHERE ORDER_DATE = ? " +
					"AND ORDER_SEQ = ?";
			PreparedStatement pstmtChild = mConn.prepareStatement(selectOrderInfoDetailSQL);
			pstmtChild.setString(1, rsParent.getString("ORDER_DATE"));
			pstmtChild.setInt(2, rsParent.getInt("ORDER_SEQ"));
			ResultSet rsChild = pstmtChild.executeQuery();
			
			while(rsChild.next()){
				OrderInfoDetailData orderInfoDetailData = new OrderInfoDetailData();
				orderInfoDetailData.setPRODUCT_CODE(rsChild.getString("PRODUCT_CODE"));
				orderInfoDetailData.setORDAR_PRICE(rsChild.getInt("ORDAR_PRICE"));
				orderInfoDetailData.setPRODUCT_QTY(rsChild.getInt("PRODUCT_QTY"));
				orderInfoDetailData.setPRODUCT_IMG(rsChild.getString("PRODUCT_IMG"));
				
				orderInfoDetailArrayList.add(orderInfoDetailData);
			}
			
			rsChild.close();
			pstmtChild.close();
			
			orderInfoRepayData.setORDER_DETAIL(orderInfoDetailArrayList);
			
			orderInfoRepayArrayList.add(orderInfoRepayData);
		}
		
		rsParent.close();
		pstmtParent.close();
		mConn.close();
		
		res.put("IS_SUCCESS", true);
		res.put("MSG", "");
		res.put("RESULT",orderInfoRepayArrayList);
		
	    out.println(new Gson().toJson(res));
	} 
	else if (request.getMethod().equals("POST")){
		StringBuilder sb = new StringBuilder();
	    BufferedReader reader = request.getReader();
	    try {
	        String line;
	        while ((line = reader.readLine()) != null) {
	            sb.append(line).append('\n');
	        }
	    } finally {
	        reader.close();
	    }
	    JSONObject res = new JSONObject();
	    PreparedStatement pstmt = null;
	    String requestString = sb.toString();
	    JsonParser jsonParser = new JsonParser();
	    JsonArray req = jsonParser.parse(requestString).getAsJsonArray();
	    for (int i = 0; i < req.size(); i++){
	   		JsonElement jsonElement = req.get(i);
	   		JsonObject jsonObject = jsonElement.getAsJsonObject();
	   		
	   		String userId = jsonObject.get("USER_ID").getAsString();
		    String orderDate = jsonObject.get("ORDER_DATE").getAsString();
		    int orderSeq = jsonObject.get("ORDER_SEQ").getAsInt();
		    String repayType = jsonObject.get("REPAY_TYPE").getAsString();
		    int repayPrice = jsonObject.get("REPAY_PRICE").getAsInt();
		    
		    String selectDate = "SELECT DATE_FORMAT(CURRENT_DATE, '%Y%m%d') AS REPAY_DATE LIMIT 1";
		   	pstmt = mConn.prepareStatement(selectDate);
		   	ResultSet rs = pstmt.executeQuery();
		   	rs.next();
		   	String repayDate = rs.getString("REPAY_DATE");
		   	
		   	String selectMaxRepaySeq = "SELECT IFNULL(MAX(REPAY_SEQ), 0) + 1 AS REPAY_SEQ " +
		   			"FROM REPAY " +
		   			"WHERE REPAY_DATE = ? " + 
		   			"LIMIT 1";
		   	pstmt = mConn.prepareStatement(selectMaxRepaySeq);
		   	pstmt.setString(1, repayDate);
		   	rs = pstmt.executeQuery();
		   	rs.next();
		   	int repaySeq = rs.getInt("REPAY_SEQ");
		   	
		   	rs.close();
		    
		    String updateOrderInfoSQL = "UPDATE ORDER_INFO " +
		    	    "SET ORDER_STATUS = '003', " +
		    		"	REPAY_DATE = ?, " +
		    	    "	REPAY_SEQ = ? " +
		    	    "WHERE USER_ID = ? " +
		    	    "AND ORDER_DATE = ? " +
		    	    "AND ORDER_SEQ = ? " +
		    	    	"AND ORDER_STATUS = '002'";
		   	pstmt = mConn.prepareStatement(updateOrderInfoSQL);
		   	pstmt.setString(1, repayDate);
		   	pstmt.setInt(2, repaySeq);
			pstmt.setString(3, userId);
			pstmt.setString(4, orderDate);
			pstmt.setInt(5, orderSeq);
			
			if (pstmt.executeUpdate() == 0){
				res.put("IS_SUCCESS", false);
				res.put("MSG", "실패");
				
			    out.println(new Gson().toJson(res));
			}
			
			String insertRepaySQL = "INSERT INTO REPAY( " +
					"REPAY_DATE, REPAY_SEQ, " + 
					"REPAY_TYPE, REPAY_PRICE) " +
					"VALUES (?, ?, " +
					"		?, ?)";
			pstmt = mConn.prepareStatement(insertRepaySQL);
			pstmt.setString(1, repayDate);
			pstmt.setInt(2, repaySeq);
			pstmt.setString(3, repayType);
			pstmt.setInt(4, repayPrice);
			
			if (pstmt.executeUpdate() == 0){
				res.put("IS_SUCCESS", false);
				res.put("MSG", "실패");
				
			    out.println(new Gson().toJson(res));
			}
	    }
	    
		pstmt.close();
		mConn.commit();
		mConn.close();
		
	   	
	   	res.put("IS_SUCCESS", true);
		res.put("MSG", "");
		
	    out.println(new Gson().toJson(res));
	} else {
		out.println("There is no method");
	}
%>