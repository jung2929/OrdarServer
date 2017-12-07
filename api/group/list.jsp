<%@ include file="../config.jsp"%>
<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8" %>
<%@ page import="org.json.simple.JSONObject"%>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="java.util.Random"%>
<%@ page import="java.util.ArrayList"%>

<%
    /*
    * 그룹 조회 API
    * Method : GET
    * Request :
    * NULL (Only Need Security Verification)
    * Response :
    * { "result" : "001"
    *   "message" : "true",
    *   "markerList": [
    *   {
    *            "orderDate" : "20170925",
    *            "orderCode" : "2",
    *            "foodList" : [
    *               {},
    *               ...
    *            ],
    *            "recipient" : "김옥분",
    *            "postalCode" : "14579",
    *            "contacts" : "010-1234-4088",
    *            "desiredTimeZone" : "낮",
    *            "dateTime" : "2017-09-24 15:13:00",
    *            "shipmentStatus" : "출고승인 대기 중",
    *            "couponCode" : "null",
    *            "totalPrice" : "175,000",
    *            "discountedPrice" : "175,000",
    *            "shopName" : "할매 돼지국밥",
    *            "shopAddress" : "제주특별자치도 제주시 첨단로 242",
    *            "groupCode" : 1
    *            "lat" : 33.450701
    *            "lon" : 126.570667
    *   },
    *   ...
    *   ]
    * }
    */

    request.setCharacterEncoding("UTF-8");
    int cnt=100;
    int similarity=-1;
//    int cnt = request.getParameter("cnt")!=null ? Integer.parseInt(request.getParameter("cnt")) : 100;
//    int similarity = request.getParameter("similarity")!=null ? Integer.parseInt(request.getParameter("similarity")) : -1;
    if(request.getParameter("cnt")!=null && !request.getParameter("cnt").equals("")){
        cnt = Integer.parseInt(request.getParameter("cnt"));
    }

    if(request.getParameter("similarity")!=null && !request.getParameter("similarity").equals("")){
        similarity = Integer.parseInt(request.getParameter("similarity"));
    }



    JSONObject res = new JSONObject();
    res.put("result", "001");
    res.put("message", "그룹핑이 완료되었습니다");
//
//    JSONArray markerList = new JSONArray();
//
//
//    JSONObject marker;
//
//    marker = new JSONObject();
//    marker.put("orderDate", "20170925");
//    marker.put("orderCode", "2");
//    marker.put("foodList", "null");
//    marker.put("recipient", "김옥분");
//    marker.put("postalCode", "14579");
//    marker.put("contacts", "010-1234-4088");
//    marker.put("desiredTimeZone", "낮");
//    marker.put("dateTime", "2017-09-24 15:13:00");
//    marker.put("shipmentStatus", "출고승인 대기 중");
//    marker.put("couponCode", "null");
//    marker.put("totalPrice", "175,000");
//    marker.put("discountedPrice", "175,000");
//    marker.put("shopName", "할매 돼지국밥");
//    marker.put("shopAddress", "제주특별자치도 제주시 첨단로 242");
//    marker.put("groupCode", "1");
//    marker.put("lat", 33.450701);
//    marker.put("lon", 126.570667);
//
//    markerList.add(marker);
//
//    marker = new JSONObject();
//    marker.put("orderDate", "20170925");
//    marker.put("orderCode", "2");
//    marker.put("foodList", "null");
//    marker.put("recipient", "김옥분");
//    marker.put("postalCode", "14579");
//    marker.put("contacts", "010-1234-4088");
//    marker.put("desiredTimeZone", "낮");
//    marker.put("dateTime", "2017-09-24 15:13:00");
//    marker.put("shipmentStatus", "출고승인 대기 중");
//    marker.put("couponCode", "null");
//    marker.put("totalPrice", "175,000");
//    marker.put("discountedPrice", "175,000");
//    marker.put("shopName", "이모네 분식점");
//    marker.put("shopAddress", "제주특별자치도 제주시 첨단로 242");
//    marker.put("groupCode", "2");
//    marker.put("lat", 33.450101);
//    marker.put("lon", 126.570167);
//
//
//
//    markerList.add(marker);
    JSONArray markerList = createMarkerList(cnt);
    JSONArray groupedMarkerList = getGroupedMarkerList(markerList);







//    JSONArray groupedMarkerList = markerList;



    JSONArray sortedMarkerList = getSortedMarkerList(groupedMarkerList, similarity);

    res.put("markerList", sortedMarkerList);
//    res.put("markerList", groupedMarkerList);

//    getNearestMarker(sortedMarkerList, (JSONObject) sortedMarkerList.get(0));
//    getMostExpensiveMarker(markerList);
//    isGrouped(markerList);
    out.println(res.toJSONString());
    //out.println(createProductList().toJSONString());




%>

<%!
    JSONArray getGroupedMarkerList(JSONArray markerList){
        JSONObject tmpMostExpensiveMarker;
        JSONObject tmpNearestMarker;


        int groupId = 0;
        int groupPrice = 0;
        double dis = 0;
        while(!isGrouped(markerList)){
            dis = 0;
            groupPrice = 0;
            tmpMostExpensiveMarker = getMostExpensiveMarker(markerList);
            tmpMostExpensiveMarker.remove("groupCode");
            tmpMostExpensiveMarker.remove("isCenter");

            tmpMostExpensiveMarker.put("groupCode", groupId);
            tmpMostExpensiveMarker.put("isCenter", true);


            groupPrice += (int) tmpMostExpensiveMarker.get("discountedValue");



            while(dis < 500 ){
                if(isGrouped(markerList)){
                    break;
                }
                if(isAllNotSimilar(markerList, (int) tmpMostExpensiveMarker.get("similarity"))){

                    break;
                }
                if(!isHaveNearestMarker(markerList,tmpMostExpensiveMarker, 700)){
                    break;
                }
                tmpNearestMarker = getNearestMarker(markerList , tmpMostExpensiveMarker);
                groupPrice += (int) tmpNearestMarker.get("discountedValue");



                dis = distance((double) tmpMostExpensiveMarker.get("lat"), (double) tmpMostExpensiveMarker.get("lon"),
                        (double) tmpNearestMarker.get("lat"), (double) tmpNearestMarker.get("lon"),
                        "K");

                tmpNearestMarker.remove("groupCode");
                tmpNearestMarker.put("groupCode", groupId);
//                tmpNearestMarker.put("dis", dis);


            }

            tmpMostExpensiveMarker.remove("groupPrice");
            tmpMostExpensiveMarker.put("groupPrice", String.format("%,d", groupPrice) );


            groupId++;
        }


        return markerList;
    }

    boolean isGrouped(JSONArray markerList){
        for(int i=0; i<markerList.size(); i++){

            boolean isGrouped = (boolean) ((JSONObject) markerList.get(i)).get("isGrouped");


            if(!isGrouped){
                return false;
            }
        }
        return true;
    }


    boolean isAllNotSimilar(JSONArray markerList, int similarity){

        int cnt =0;
        for(int i=0; i<markerList.size(); i++){
            boolean isGrouped = (boolean) ((JSONObject) markerList.get(i)).get("isGrouped");
            if(isGrouped){
                continue;
            }

            //같은 유사도 필터
            int tmpSimilarity = (int) ((JSONObject) markerList.get(i)).get("similarity");
            if((similarity != tmpSimilarity)){
                continue;
            }
            cnt++;
        }
        if(cnt<=1) {
            return true;
        }
        else {
            return false;
        }
    }

    JSONObject getMostExpensiveMarker(JSONArray markerList){
        int max = -1;
        int idx = -1;
        for(int i=0; i<markerList.size(); i++){
            //그룹핑되지 않은 가맹점만 그룹핑함
            boolean isGrouped = (boolean) ((JSONObject) markerList.get(i)).get("isGrouped");
            if(isGrouped){
                continue;
            }

            int price = (int) ((JSONObject) markerList.get(i)).get("discountedValue");

            if(max < price){
                max = price;
                idx = i;
            }
        }

        JSONObject mostExpensiveMarker = (JSONObject) markerList.get(idx);
        mostExpensiveMarker.remove("isGrouped");
        mostExpensiveMarker.put("isGrouped", true);



        return mostExpensiveMarker;

    }


    JSONObject getNearestMarker(JSONArray markerList , JSONObject marker){
        double min = Double.MAX_VALUE;
        int idx = -1;
        double dis=0;
        for(int i=0; i<markerList.size(); i++){
            //그룹핑되지 않은 가맹점만 그룹핑함
            boolean isGrouped = (boolean) ((JSONObject) markerList.get(i)).get("isGrouped");
            if(isGrouped){
                continue;
            }

            //같은 유사도 가맹점 끼리만 그룹핑함
            int tmpSimilarity = (int) ((JSONObject) markerList.get(i)).get("similarity");
            if((int) marker.get("similarity") != tmpSimilarity){
                continue;
            }

            dis = distance((double) marker.get("lat"), (double) marker.get("lon"),
                    (double) ((JSONObject)markerList.get(i)).get("lat"),  (double) ((JSONObject)markerList.get(i)).get("lon"),
                    "K");


            if(min > dis){
                min = dis;
                idx = i;
            }
        }
        JSONObject nearestMarker = (JSONObject) markerList.get(idx);
        nearestMarker.remove("isGrouped");
        nearestMarker.put("isGrouped", true);
//        nearestMarker.put("neardis", min);
        return nearestMarker;
    }

    boolean isHaveNearestMarker(JSONArray markerList , JSONObject marker, double distance) {
        double min = Double.MAX_VALUE;
        for(int i=0; i<markerList.size(); i++){
            //그룹핑되지 않은 가맹점만 그룹핑함
            boolean isGrouped = (boolean) ((JSONObject) markerList.get(i)).get("isGrouped");
            if(isGrouped){
                continue;
            }

            //같은 유사도 가맹점 끼리만 그룹핑함
            int tmpSimilarity = (int) ((JSONObject) markerList.get(i)).get("similarity");
            if((int) marker.get("similarity") != tmpSimilarity){
                continue;
            }

            double dis = distance((double) marker.get("lat"), (double) marker.get("lon"),
                    (double) ((JSONObject)markerList.get(i)).get("lat"),  (double) ((JSONObject)markerList.get(i)).get("lon"),
                    "K");


            if(min > dis){
                min = dis;
            }
        }

        if(min > distance){
            return false;
        }

        return true;
    }
    
    JSONArray createProductList(){
    	        JSONArray productList = new JSONArray();
    	        JSONObject product;
    	        Random rd = new Random();
    	//        String productCode;
    	//        String mainCategory;
    	//        String subCategory;
    	//        String productStatus;
    	//        int[] productPrice = {
    	//                7900, 43500, 4000, 11500, 7800,
    	//                12300, 4500, 6300, 1200, 5000,
    	//                8700, 14500, 23000, 10000, 23000
    	//        };
    	        ArrayList<String> productTitleDB = new ArrayList<>();
    	
    	        String[] productTitle = {"일등급 유정란 30구 ", "순창 태양표 고추장 ", "깐 양파 20개 (망)", "오뚜기 라면사리 20개입 1박스", "하림 안심 닭가슴살 500g (팩)",
    	                "백설 콩기름 100% 1L", "해남 직배송 고구마 1kg", "[동원에프앤비] 동원참치1880g", "{굴철철}수출용굴/냉동굴10kg~20kg/", "두원식품 순후추 200g /고추냉이/",
    	                "수입 볶음참깨1kg 수입들깨 ", "배대감 식자재 볶음참깨 1kg", "칠갑농산 칠갑쫄면사리(식자재)2kg", "식자재 지퍼백 25cm 32cm 50매", "중국산 건목이버섯 1KG 직수입",
    	                "[하림] 프로라인 치킨너겟1kgx2봉", "미화합동 찌개된장 14kg", "건어물녀 반찬 가문어 슬라이스 1kg", "식자재 벌크 종합캔디", "[CJ] 이츠웰 쇠고기 진한다시 1kg",
    	                "돌자반볶음 400g", "월남쌈 베트남쌀국수", "중국요리 식자재 30종 누룽지", "[오뚜기] 라면사리 진라면 참라면", "대흥명가 수수 쌀 조청"
    	        };
    	
    	        for (String p : productTitle) {
    	            productTitleDB.add(p);
    	        }
    	
    	//        String[] productQty;
    	        for(int i=0; i<rd.nextInt(15)+5; i++){
    	            product = new JSONObject();
    	            int next = rd.nextInt(productTitleDB.size() - 1);
    	            product.put("PRODUCT_TITLE", productTitleDB.get(next));
    	            product.put("PRODUCT_CODE", "TEST" + i);
    	            product.put("PRODUCT_PRICE", Integer.parseInt(rd.nextInt(100) + "00"));
    	            product.put("PRODUCT_QTY", rd.nextInt(50));
    	            productTitleDB.remove(next);
    	            productList.add(product);
    	        }
    	
    	        return productList;
    	
    	    }

    JSONArray createMarkerList(int cnt){
    		String[] productTitle = {"일등급 유정란 30구 ", "순창 태양표 고추장 ", "깐 양파 20개 (망)", "오뚜기 라면사리 20개입 1박스", "하림 안심 닭가슴살 500g (팩)",
    			                "백설 콩기름 100% 1L", "해남 직배송 고구마 1kg", "[동원에프앤비] 동원참치1880g", "{굴철철}수출용굴/냉동굴10kg~20kg/", "두원식품 순후추 200g /고추냉이/",
    			                "수입 볶음참깨1kg 수입들깨 ", "배대감 식자재 볶음참깨 1kg", "칠갑농산 칠갑쫄면사리(식자재)2kg", "식자재 지퍼백 25cm 32cm 50매", "중국산 건목이버섯 1KG 직수입",
    			                "[하림] 프로라인 치킨너겟1kgx2봉", "미화합동 찌개된장 14kg", "건어물녀 반찬 가문어 슬라이스 1kg", "식자재 벌크 종합캔디", "[CJ] 이츠웰 쇠고기 진한다시 1kg",
    			                "돌자반볶음 400g", "월남쌈 베트남쌀국수", "중국요리 식자재 30종 누룽지", "[오뚜기] 라면사리 진라면 참라면", "대흥명가 수수 쌀 조청"
    		};
        JSONArray markerList = new JSONArray();
        JSONObject marker;
        Random rd = new Random();
        for(int i=0 ; i<cnt; i++){
            double randomLat = ((rd.nextInt() % 10000000) * 0.000000001);
            double randomLon = ((rd.nextInt() % 10000000) * 0.000000001);
//            double similarity = (((rd.nextInt() % 100) + 200) * 0.1);
            double similarity = (rd.nextInt(6));
            int price = (rd.nextInt(800000));
            marker = new JSONObject();
            marker.put("orderDate", "20170925");						//ORDER_DATE
            marker.put("orderCode", "2");							//ORDER_SEQ
            marker.put("foodList", createProductList());
            marker.put("recipient", i + " 번째 가맹점");				//RCVD_NAME
            marker.put("postalCode", "14579");						//RCVD_ZIP_CODE
            marker.put("contacts", "010-1234-4088");					//RCVD_CONTACT
            marker.put("desiredTimeZone", "낮");						//ORDER_RCVD_TYPE
            marker.put("shipmentStatus", "출고승인 대기 중");				//ORDER_STATUS -> COMMON_TB's CODE_NAME
            marker.put("couponCode", "null");						//COUPON_CODE
            marker.put("totalPrice", String.format("%,d", price));	//ORIGIN_TOT_PRICE
            marker.put("totalValue", price);							//''
            marker.put("discountedPrice", String.format("%,d", price)); //DSCNT_TOT_PRICE
            marker.put("discountedValue", price);						//''
            marker.put("shopAddress", "제주특별자치도 제주시 첨단로 242");	//RCVD_ADDR + RCVD_ADDR_DETAIL
            marker.put("groupCode", (int) similarity);				//1
            marker.put("lat", (37.504683 + randomLat));
            marker.put("lon", (127.048930 + randomLon));
            marker.put("isGrouped", false);
            marker.put("similarity", (int) similarity);
            marker.put("isCenter", false);
            marker.put("groupPrice", "-");
//            marker.put("lon", (randomLon));

            markerList.add(marker);
        }

        return markerList;
    }

    JSONArray getSortedMarkerList(JSONArray markerList, int similarity){
        JSONArray sortedMarkerList = new JSONArray();
        if(similarity == -1){
            return markerList;
        }
        for(int i=0; i<markerList.size(); i++){

//            sortedMarkerList.add(i);
            if((int) ((JSONObject)markerList.get(i)).get("similarity") == similarity){
                sortedMarkerList.add((JSONObject) markerList.get(i));

            }
        }
        return sortedMarkerList;
    }

    private static double distance(double lat1, double lon1, double lat2, double lon2, String unit) {
        double theta = lon1 - lon2;
        double dist = Math.sin(deg2rad(lat1)) * Math.sin(deg2rad(lat2)) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.cos(deg2rad(theta));
        dist = Math.acos(dist);
        dist = rad2deg(dist);
        dist = dist * 60 * 1.1515;
        if (unit == "K") {
            //km
            dist = dist * 1.609344;
            //m
            dist = dist * 1000.0;
        } else if (unit == "N") {
            dist = dist * 0.8684;
        }

        return (dist);
    }

    private static double deg2rad(double deg) {
        return (deg * Math.PI / 180.0);
    }

    private static double rad2deg(double rad) {
        return (rad * 180 / Math.PI);
    }

%>
