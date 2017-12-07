<%@ include file="../config.jsp"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="ordarserver.OrderInfoData" %>
<%@ page import="ordarserver.OrderInfoDetailData" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="java.io.BufferedReader" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%	
	if (request.getMethod().equals("GET")){
	JSONObject res = new JSONObject();
		
		String selectOrderInfoSQL = "SELECT ORDER_DATE, ORDER_SEQ, ARRIVAL_DATE " +
				"FROM ORDER_INFO " +
				"WHERE USER_ID = ? " +
				"AND ORDER_STATUS = '001' " +
				"ORDER BY ORDER_DATE DESC, ORDER_SEQ DESC " +
				"LIMIT 10;";
		PreparedStatement pstmtParent = mConn.prepareStatement(selectOrderInfoSQL);
		pstmtParent.setString(1, "root");
		ResultSet rsParent = pstmtParent.executeQuery();
		
		ArrayList<OrderInfoData> orderInfoArrayList = new ArrayList<>();
		
		while(rsParent.next()){
			ArrayList<OrderInfoDetailData> orderInfoDetailArrayList = new ArrayList<>();
			OrderInfoData orderInfoData = new OrderInfoData();
			orderInfoData.setORDER_DATE(rsParent.getString("ORDER_DATE"));
			orderInfoData.setORDER_SEQ(rsParent.getInt("ORDER_SEQ"));
			orderInfoData.setARRIVAL_DATE(rsParent.getString("ARRIVAL_DATE"));
			
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
			
			orderInfoData.setORDER_DETAIL(orderInfoDetailArrayList);
			
			orderInfoArrayList.add(orderInfoData);
		}
		
		rsParent.close();
		pstmtParent.close();
		mConn.close();
		
		res.put("IS_SUCCESS", true);
		res.put("MSG", "");
		res.put("RESULT",orderInfoArrayList);
		
	    out.println(new Gson().toJson(res));
	} else if (request.getMethod().equals("POST")){
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
	    		
	    String requestString = new String(sb.toString().getBytes("iso-8859-1"), "utf-8");
	    
	    JsonParser jsonParser = new JsonParser();
	    JsonObject req = jsonParser.parse(requestString).getAsJsonObject();
	    String userId = req.get("USER_ID").getAsString();
	   	String rcvdName = req.get("RCVD_NAME").getAsString();
	   	String rcvdZipCode = req.get("RCVD_ZIP_CODE").getAsString();
	   	String rcvdAddr = req.get("RCVD_ADDR").getAsString();
	   	String rcvdAddrDetail = req.get("RCVD_ADDR_DETAIL").getAsString();
	   	String rcvdContact = req.get("RCVD_CONTACT").getAsString();
	   	String orderRcvdType = req.get("ORDER_RCVD_TYPE").getAsString();
	   	String remark = req.get("REMARK").getAsString();
	   	int originTotPrice = req.get("ORIGIN_TOT_PRICE").getAsInt();
	   	int dscntTotPrice = req.get("DSCNT_TOT_PRICE").getAsInt();
	   	String couponCode = req.get("COUPON_CODE").getAsString();
	   	JsonArray orderInfoDetailJsonArray = req.get("ORDER_DETAIL").getAsJsonArray();
	   	
	   	String selectDates = "SELECT DATE_FORMAT(CURRENT_DATE, '%Y%m%d') AS ORDER_DATE, " +
	   			"DATE_FORMAT(CURRENT_DATE + INTERVAL +7 DAY , '%Y%m%d') AS ARRIVAL_DATE LIMIT 1";
	   	PreparedStatement pstmt = mConn.prepareStatement(selectDates);
	   	ResultSet rs = pstmt.executeQuery();
	   	rs.next();
	   	String orderDate = rs.getString("ORDER_DATE");
	   	String arrivalDate = rs.getString("ARRIVAL_DATE");
	   	
	   	String selectMaxOrderSeq = "SELECT IFNULL(MAX(ORDER_SEQ), 0) + 1 AS ORDER_SEQ " +
	   			"FROM ORDER_INFO " +
	   			"WHERE ORDER_DATE = ? " + 
	   			"LIMIT 1";
	   	pstmt = mConn.prepareStatement(selectMaxOrderSeq);
	   	pstmt.setString(1, orderDate);
	   	rs = pstmt.executeQuery();
	   	rs.next();
	   	int orderSeq = rs.getInt("ORDER_SEQ");
	   	
	   	pstmt.close();
	   	rs.close();
	   	
	   	String insertOrderInfoSQL = "INSERT INTO ORDER_INFO(" +
	   			"ORDER_DATE, ORDER_SEQ, USER_ID, " + 
	   			"RCVD_NAME, RCVD_ZIP_CODE, RCVD_ADDR, " + 
	   			"RCVD_ADDR_DETAIL, RCVD_CONTACT, ORDER_RCVD_TYPE, " + 
	   			"REMARK, ORDER_STATUS, ORIGIN_TOT_PRICE, " +
	   			"DSCNT_TOT_PRICE, ARRIVAL_DATE, COUPON_CODE, " +
	   			"REPAY_DATE, REPAY_SEQ, " +
	   			"GROUP_DATE, GROUP_SEQ) " +
	   			"VALUES (?, ?, ?, " +
	   			"		?, ?, ?, " +
	   			"		?, ?, ?, " + 
	   			"		?, '001', ?, " +
	   			"		? ,?, ?, " +
	   			"		NULL, NULL, " +
	   			"		NULL, NULL)";
	   	PreparedStatement pstmtParent = mConn.prepareStatement(insertOrderInfoSQL);
		pstmtParent.setString(1, orderDate);
		pstmtParent.setInt(2, orderSeq);
		pstmtParent.setString(3, userId);
		pstmtParent.setString(4, rcvdName);
		pstmtParent.setString(5, rcvdZipCode);
		pstmtParent.setString(6, rcvdAddr);
		pstmtParent.setString(7, rcvdAddrDetail);
		pstmtParent.setString(8, rcvdContact);
		pstmtParent.setString(9, orderRcvdType);
		pstmtParent.setString(10, remark);
		pstmtParent.setInt(11, originTotPrice);
		pstmtParent.setInt(12, dscntTotPrice);
		pstmtParent.setString(13, arrivalDate);
		pstmtParent.setString(14, couponCode);
		
		JSONObject res = new JSONObject();
		
		if (pstmtParent.executeUpdate() == 0){
			res.put("IS_SUCCESS", false);
			res.put("MSG", "실패");
			
		    out.println(new Gson().toJson(res));
		}
		
		pstmtParent.close();
		
		String insertOrderInfoDetailSQL = "INSERT INTO ORDER_INFO_DETAIL(" +
   				"ORDER_DATE, ORDER_SEQ, ORDER_SEQ_NO, " +
   				"PRODUCT_CODE, PRODUCT_QTY, " +
   				"ORIGIN_PRICE, DSCNT_PRICE) " +
   				"VALUES (?, ?, ?," +
   				"		?, ?, " +
   				"		?, ?)";
		PreparedStatement pstmtChild = mConn.prepareStatement(insertOrderInfoDetailSQL);
		
	   	for (int i = 0; i < orderInfoDetailJsonArray.size(); i++){
	   		JsonElement jsonElement = orderInfoDetailJsonArray.get(i);
	   		JsonObject jsonObject = jsonElement.getAsJsonObject();
	   		String productCode = jsonObject.get("PRODUCT_CODE").getAsString();
	   		int productQty = jsonObject.get("PRODUCT_QTY").getAsInt();
	   		int originPrice = jsonObject.get("ORIGIN_PRICE").getAsInt();
	   		int dscntPrice = jsonObject.get("DSCNT_PRICE").getAsInt();
	   		
	   		pstmtChild.setString(1, orderDate);
	   		pstmtChild.setInt(2, orderSeq);
	   		int orderSeqNo = i + 1;
	   		pstmtChild.setInt(3, orderSeqNo);
	   		pstmtChild.setString(4, productCode);
	   		pstmtChild.setInt(5, productQty);
	   		pstmtChild.setInt(6, originPrice);
	   		pstmtChild.setInt(7, dscntPrice);
	   		pstmtChild.addBatch();
	   	}
	   	
	   	int[] rsCnts = pstmtChild.executeBatch();
	   	
	   	pstmtChild.close();
		mConn.commit();
		mConn.close();
		
	   	res.put("IS_SUCCESS", true);
		res.put("MSG", "");
		
	    out.println(new Gson().toJson(res));
	} else {
		out.println("There is no method");
	}
%>