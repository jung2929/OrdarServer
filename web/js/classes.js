class Shop {

    constructor(idx,
                marker,
                overlay,
                orderDate,
                orderCode,
                foodList,
                recipient,
                postalCode,
                contacts,
                desiredTimeZone,
                dateTime,
                shipmentStatus,
                couponCode,
                totalPrice,
                discountedPrice,
                shopName,
                shopAddress,
                groupCode) {

        this.idx = idx;

        this.marker = marker; // 마커
        this.overlay = overlay; // 커스텀오버레이
        overlay.setMap(null);

        this.orderDate = orderDate; // 주문일자
        this.orderCode = orderCode; // 주문차수
        this.foodList = foodList; // 식품리스트
        // console.log(foodList);
        this.recipient = recipient; // 수령인
        this.postalCode = postalCode; // 우편번호
        this.contacts = contacts; // 연락처
        this.desiredTimeZone = desiredTimeZone; // 희망수령시간대
        this.dateTime = dateTime; // 주문요청시간
        this.shipmentStatus = shipmentStatus; // 배송현황
        this.couponCode = couponCode; // 쿠폰코드
        this.totalPrice = totalPrice; // 총가격
        this.discountedPrice = discountedPrice; // 할인

        this.shopName; // 가맹점명
        this.shopAddress; // 가맹점주소

        this.groupCode = groupCode;

        // this.overlay = this.getOverlay(marker); // 커스텀오버레이


        // daum.maps.event.addListener(marker, 'click', function () {
        //     // console.log(overlay);
        //     setOrderInfo(marker);
        //     // overlay.setMap(marker.getMap());
        // });


    }




}