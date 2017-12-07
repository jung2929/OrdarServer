var currentPosition = [37.504683, 127.048930];

var mapContainer = document.getElementById('map'), // 지도의 중심좌표
    mapOption = {
        center: new daum.maps.LatLng(currentPosition[0], currentPosition[1]), // 지도의 중심좌표
        level: 5 // 지도의 확대 레벨
    };

var map = new daum.maps.Map(mapContainer, mapOption); // 지도를 생성합니다

var shopList = new Array();
var groupList = new Array();

var customOverlay; //마우스오버
var infowindow;
var selectedMarker = null; //클릭된마커를 담는 변수
var selectedGroup = null; //클릭된그룹을 담는 변수

$("#getGroupListBtn").click(function () {
    shopList.forEach(function (value, index) {
        value.marker.setMap(null);
    });
    groupList.forEach(function (value, index) {
        value.setMap(null);
    });

    shopList = [];
    // var cnt = $("#cnt").val();
    // var similarity = $("#similarity").val();
    var cnt = 100;
    var similarity = 1;

    jQuery.ajax({
        type: "GET",
        url: "../../api/group/list.jsp?cnt=" + cnt + "&similarity=" + similarity,
        dataType: "JSON",
        success: function (data) {
            console.log(data.markerList);
            data.markerList.forEach(function (value, index) {

                shopList.push(new Shop(
                    index,
                    createMarker(map, [value.lat, value.lon], value.groupCode, index),
                    createOverlay(map, [value.lat, value.lon], createContent(value.shopName, index, value.groupCode, value.discountedPrice, value.similarity, value.isCenter, value.groupPrice)),
                    value.orderDate,
                    value.orderCode,
                    value.foodList,
                    value.recipient,
                    value.postalCode,
                    value.contacts,
                    value.desiredTimeZone,
                    value.dateTime,
                    value.shipmentStatus,
                    value.couponCode,
                    value.totalPrice,
                    value.discountedPrice,
                    value.shopName,
                    value.shopAddress,
                    value.groupCode
                    )
                );


            });

        },
        complete: function (data) {
            // console.log(shopList[0].marker.getPosition().jb);
            // console.log(data);

            shopList.forEach(function (value, index) {

                drawGroup(value.groupCode);
            });





        },
        error: function (xhr, status, error) {
            console.log(error);
            alert("에러발생");
        }
    });
});

// 다각형을 생상하고 이벤트를 등록하는 함수입니다
function displayArea(area) {

    // 다각형을 생성합니다
    var polygon = new daum.maps.Polygon({
        map: map, // 다각형을 표시할 지도 객체
        path: area.path,
        strokeWeight: 0,
        strokeColor: '#FFF',
        strokeOpacity: 0.9,
        fillColor: '#6fccd7',
        fillOpacity: 0.12
    });


    groupList.push(polygon);
    // groupList.push({"group" : polygon , "pivot" : { "lat" : pivotLat, "lon": pivotLon}});


    // 다각형에 mouseover 이벤트를 등록하고 이벤트가 발생하면 폴리곤의 채움색을 변경합니다
    // 지역명을 표시하는 커스텀오버레이를 지도위에 표시합니다
    daum.maps.event.addListener(polygon, 'mouseover', function (mouseEvent) {
        polygon.setOptions({fillColor: '#09f'});

        // customOverlay.setContent('<div class="area">' + area.name + '</div>');

        // customOverlay.setPosition(mouseEvent.latLng);
        // customOverlay.setMap(map);
    });

    // 다각형에 mousemove 이벤트를 등록하고 이벤트가 발생하면 커스텀 오버레이의 위치를 변경합니다
    daum.maps.event.addListener(polygon, 'mousemove', function (mouseEvent) {
        customOverlay.setPosition(mouseEvent.latLng);
    });

    // 다각형에 mouseout 이벤트를 등록하고 이벤트가 발생하면 폴리곤의 채움색을 원래색으로 변경합니다
    // 커스텀 오버레이를 지도에서 제거합니다
    daum.maps.event.addListener(polygon, 'mouseout', function () {
        polygon.setOptions({fillColor: '#6fccd7'});
        customOverlay.setMap(null);

    });

    // 다각형에 click 이벤트를 등록하고 이벤트가 발생하면 다각형의 이름과 면적을 인포윈도우에 표시합니다
    daum.maps.event.addListener(polygon, 'click', function (mouseEvent) {
        // var content = '<div class="info">' +
        //     '   <div class="title">그룹 번호 : ' + area.name + ' 번</div>' +
        //     '   <div class="size">총 면적 : 약 ' + Math.floor(polygon.getArea()) + ' m<sup>2</sup></area>' +
        //     '</div>';
        //
        // infowindow.setContent(content);
        // infowindow.setPosition(mouseEvent.latLng);
        // infowindow.setMap(map);
        if (!selectedGroup || selectedGroup !== polygon) {
            !!selectedGroup && selectedGroup.setOptions({strokeWeight: 0, strokeColor: '#fff'});
            if(selectedMarker!=null)  selectedMarker.setImage(selectedMarker.normalImage);

            polygon.setOptions({strokeWeight: 2, strokeColor: '#ff7876'});

        }
        selectedGroup = polygon;
        selectedMarker = null;



        var groupedShopList = new Array();


        shopList.forEach(function (value, index) {

            if (value.groupCode == area.name){
                // console.log(index);
                groupedShopList.push(value);

            }

        });

        console.log(groupedShopList);
        setOrderInfoByGroup(groupedShopList);
    });
}


// 커스텀 오버레이를 닫기 위해 호출되는 함수
function closeOverlay(position) {
    // console.log(shopList[position]);
    shopList[position].overlay.setMap(null);
}

function createMarker(map, position, similarity, index) {

    var imageSize = new daum.maps.Size(25, 25),
        imageOptions = {
            spriteOrigin: new daum.maps.Point(0, 0),
            spriteSize: new daum.maps.Size(25, 25)
        },
        markerImageSrc = '../img/ordar-map/marker/';

    var selectedMarkerImageSrc = markerImageSrc + 'marker_selected.svg';
    markerImageSrc += 'marker.svg';
    // switch (similarity % 6 + 1) {
    //     case 1:
    //         markerImageSrc += 'marker.svg';
    //         break;
    //     case 2:
    //         markerImageSrc += 'marker02.png';
    //         break;
    //     case 3:
    //         markerImageSrc += 'marker03.png';
    //         break;
    //     case 4:
    //         markerImageSrc += 'marker04.png';
    //         break;
    //     case 5:
    //         markerImageSrc += 'marker05.png';
    //         break;
    //     case 6:
    //         markerImageSrc += 'marker06.png';
    //         break;
    // }

    var overImageSize = new daum.maps.Size(30, 30),
        overImageOptions = {
            spriteOrigin: new daum.maps.Point(0, 0),
            spriteSize: new daum.maps.Size(30, 30)
        }

    var normalImage = createMarkerImage(markerImageSrc, imageSize, imageOptions);
    var selectedImage = createMarkerImage(selectedMarkerImageSrc, overImageSize, overImageOptions);
    var overImage = createMarkerImage(markerImageSrc, overImageSize, overImageOptions);



    var marker = new daum.maps.Marker({
        map: map,
        position: new daum.maps.LatLng(position[0], position[1]),
        image: normalImage
    });
    marker.normalImage = normalImage;


    // 마커에 mouseover 이벤트를 등록합니다
    daum.maps.event.addListener(marker, 'mouseover', function() {

        // 클릭된 마커가 없고, mouseover된 마커가 클릭된 마커가 아니면
        // 마커의 이미지를 오버 이미지로 변경합니다
        if (!selectedMarker || selectedMarker !== marker) {
            marker.setImage(overImage);
        }
    });

    // 마커에 mouseout 이벤트를 등록합니다
    daum.maps.event.addListener(marker, 'mouseout', function() {

        // 클릭된 마커가 없고, mouseout된 마커가 클릭된 마커가 아니면
        // 마커의 이미지를 기본 이미지로 변경합니다
        if (!selectedMarker || selectedMarker !== marker) {
            marker.setImage(normalImage);
        }
    });

    // 마커에 click 이벤트를 등록합니다
    daum.maps.event.addListener(marker, 'click', function() {
        if (!selectedMarker || selectedMarker !== marker) {
            !!selectedMarker && selectedMarker.setImage(selectedMarker.normalImage);
            if(selectedGroup!=null) !!selectedGroup && selectedGroup.setOptions({strokeWeight: 0, strokeColor: '#fff'});

            marker.setImage(selectedImage);

            // console.log(marker);
            setOrderInfo(shopList[index]);


        }
        selectedMarker = marker;
        selectedGroup = null;
    });

    return marker

}

// 마커이미지의 주소와, 크기, 옵션으로 마커 이미지를 생성하여 리턴하는 함수입니다
function createMarkerImage(src, size, options) {
    var markerImage = new daum.maps.MarkerImage(src, size, options);
    return markerImage;
}

function createOverlay(map, position, content) {
    // console.log(content);
    return new daum.maps.CustomOverlay({
        content: content,
        map: map,
        position: new daum.maps.LatLng(position[0], position[1])
    });
}

function createContent(shopName, idx, groupCode, discountedPrice, similarity, isCenter, groupPrice) {
    // var content = '<div class="wrap">' +
    //     '    <div class="info">' +
    //     '        <div class="title">' +
    //     shopName +
    //     '            <div class="close"  title="닫기" id="1" onclick="closeOverlay(' + idx + ')"></div>' +
    //     '        </div>' +
    //     '        <div class="body">' +
    //     '            <div class="img">' +
    //     '                <img src="http://cfile181.uf.daum.net/image/250649365602043421936D" width="73" height="80">' +
    //     '           </div>' +
    //     '            <div class="desc">' +
    //     '                <div class="ellipsis">식품군 유사도 : ' + similarity + '</div>' +
    //     // '                <div class="jibun ellipsis">(우) 63309 (지번) 영평동 2181</div>' +
    //     '                <div class="jibun ellipsis">예상 주문 가격 :' + discountedPrice + ' 원</div>' +
    //     '                <div class="jibun ellipsis">그룹 코드 :' + groupCode + '</div>' +
    //     '                <div class="jibun ellipsis">중심 가맹점 :' + isCenter + '</div>' +
    //     '                <div class="jibun ellipsis">그룹 전체 가격 :' + groupPrice + ' 원</div>' +
    //
    //     // '                <div><a href="#" target="_blank" class="link">홈페이지</a></div>' +
    //     '            </div>' +
    //     '        </div>' +
    //     '    </div>' +
    //     '</div>';

    // return content;

}


function getConvexHull(markerList, groupCode) {

    var tmpMarkerList = new Array();

    markerList.forEach(function (value, index) {
        // console.log(index);
        if (value.groupCode == groupCode){
            tmpMarkerList.push(value);

        }

    });

    // //LOG
    // tmpMarkerList.forEach(function (value, index) {
    //     console.log(value);
    // });
    // console.log("-----------------");
    tmpMarkerList.sort(function (a, b) {
        return a.marker.getPosition().jb != b.marker.getPosition().jb ?
            a.marker.getPosition().jb - b.marker.getPosition().jb : a.marker.getPosition().ib - b.marker.getPosition().ib;
    });

    // //LOG
    // tmpMarkerList.forEach(function (value, index) {
    //     console.log(value);
    // });


    var n = tmpMarkerList.length;
    var hull = [];

    for (var i = 0; i < 2 * n; i++) {
        var j = i < n ? i : 2 * n - 1 - i;
        while (hull.length >= 2 && removeMiddle(hull[hull.length - 2], hull[hull.length - 1], tmpMarkerList[j]))
            hull.pop();
        hull.push(tmpMarkerList[j]);
    }

    hull.pop();
    // console.log("-----------------");
    // //LOG
    // hull.forEach(function (value, index) {
    //     console.log(value);
    // });

    return hull;
}

function removeMiddle(a, b, c) {
    var cross = ((a.marker.getPosition().jb - b.marker.getPosition().jb) * (c.marker.getPosition().ib - b.marker.getPosition().ib)) -
        ((a.marker.getPosition().ib - b.marker.getPosition().ib) * (c.marker.getPosition().jb - b.marker.getPosition().jb));
    var dot = (a.marker.getPosition().jb - b.marker.getPosition().jb) * (c.marker.getPosition().jb - b.marker.getPosition().jb)
        + (a.marker.getPosition().ib - b.marker.getPosition().ib) * (c.marker.getPosition().ib - b.marker.getPosition().ib);
    // console.log("cross : " + cross + ", dot : " + dot);

    return cross < 0 || cross == 0 && dot <= 0;
}

function drawGroup(similarity){

    var hullList = getConvexHull(shopList, similarity)

    var totalLat=0;
    var totalLon=0;

    hullList.forEach(function (value, index) {
        totalLat+=value.marker.getPosition().jb; //위도
        totalLon+=value.marker.getPosition().ib; //경도
    });

    var pivotLat = totalLat / hullList.length;
    var pivotLon = totalLon / hullList.length;

    // new daum.maps.Marker({
    //     map: map,
    //     position: new daum.maps.LatLng(pivotLat, pivotLon)
    // });
    if(hullList.length <= 2){
        return;
    }
    var path = new Array();
    hullList.forEach(function (value, index) {
        var broadLat = ((value.marker.getPosition().jb - pivotLat) / 2) + value.marker.getPosition().jb;
        var broadLon = ((value.marker.getPosition().ib - pivotLon) / 2) + value.marker.getPosition().ib;
        // var broadLat = value.marker.getPosition().jb;
        // var broadLon = value.marker.getPosition().ib;
        path.push(new daum.maps.LatLng(broadLat, broadLon ));
    });
    var areas = [
        {
            name: hullList[0].groupCode,
            path: path
        }
    ];
    customOverlay = new daum.maps.CustomOverlay({});
    infowindow = new daum.maps.InfoWindow({removable: true});
    // 지도에 영역데이터를 폴리곤으로 표시합니다
    for (var i = 0, len = areas.length; i < len; i++) {
        displayArea(areas[i]);
    }
}

function setOrderInfo(shop){
    var productList = "";
    var totalPrice = 0;
    var totalQty = 0;
    // console.log(shop);
    shop.foodList.forEach(function (value, index) {
        totalPrice += value.PRODUCT_PRICE;
        totalQty += value.PRODUCT_QTY;
        productList += getProductList(value);
    });
    var content = '' +
    '<div class="block">' +
        '<div class="block-header">' +
        '<div><b>상호명</b> '+shop.recipient+'</div>' +
    '</div>'+
    '<div class="block-content bg-gray-lighter">'+
        '<div class="row items-push">'+
        '<div class="col-lg-4 visible-lg">'+
        '<div class="font-w600">주문 요청 날짜</div>'+
    '<div class="">'+shop.orderDate+'</div>'+
    '</div>'+
    '<div class="col-lg-4 col-xs-6">'+
        '<div class="font-w600">총 상품개수</div>'+
    '<div class="">'+totalQty+'건</div>'+
    '</div>'+
    '<div class="col-lg-4 col-xs-6">'+
        '<div class="font-w600">총 오다가</div>'+
    '<div class="text-primary font-w600" style="font-size:160%; display: inline-block;">'+numberWithCommas(totalPrice)+'</div><div style="font-size:120%; display: inline-block;" class="text-primary font-w600">원</div>'+
    '</div>'+
    '</div>'+
    '</div>'+
    '<div class="block-content">'+
        '<div class="pull-t pull-r-l">'+
        '<div class="remove-margin-b">'+
        '<div>'+
        '<table class="table remove-margin-b font-s13">'+
        '<tbody>'+
        productList +
    '</tbody>'+
    '</table>'+
    '</div>'+
    '</div>'+
    '</div>'+
    '</div>'+
    '</div>'+
    '';


    document.getElementById('order_info').innerHTML = content;
}

function setOrderInfoByGroup(shopList){
    // alert("asd");
    var productList = "";
    var totalPrice = 0;
    var totalQty = 0;
    // console.log(shop);
    shopList.forEach(function (value, index) {
        value.foodList.forEach(function (value, index) {
            totalPrice += value.PRODUCT_PRICE;
            totalQty += value.PRODUCT_QTY;
            productList += getProductList(value);
        });
    });
    var content = '' +
        '<div class="block">' +
        '<div class="block-header">' +
        '<div><b>그룹명</b> '+shopList[0].groupCode+'</div>' +
        '</div>'+
        '<div class="block-content bg-gray-lighter">'+
        '<div class="row items-push">'+
        '<div class="col-lg-6 col-xs-6">'+
        '<div class="font-w600">총 상품개수</div>'+
        '<div class="">'+totalQty+'건</div>'+
        '</div>'+
        '<div class="col-lg-6 col-xs-6">'+
        '<div class="font-w600">총 오다가</div>'+
        '<div class="text-primary font-w600" style="font-size:160%; display: inline-block;">'+numberWithCommas(totalPrice)+'</div><div style="font-size:120%; display: inline-block;" class="text-primary font-w600">원</div>'+
        '</div>'+
        '</div>'+
        '</div>'+
        '<div class="block-content">'+
        '<div class="pull-t pull-r-l">'+
        '<div class="remove-margin-b">'+
        '<div>'+
        '<table class="table remove-margin-b font-s13">'+
        '<tbody>'+
        productList +
    '</tbody>'+
    '</table>'+
    '<button class="btn btn-minw btn-primary" style="width:100%; height:50px;"'+
    'type="button" onclick="alert(\'주문이 승인되었습니다.\');">주문 요청 승인하기'+
    '</button>'+
    '</div>'+
    '</div>'+
    '</div>'+
    '</div>'+
    '</div>'+

    '';

    // console.log(content);

    document.getElementById('order_info').innerHTML = content;
}

function getProductList(product) {
    var content =
        '<tr>'+
        '<td style="font-size: 90%; color:#4b4b4b;">'+
        product.PRODUCT_TITLE+
        '</td>'+
        '<td class="hidden-xs text-muted text-right" style="width: 60px;">'+product.PRODUCT_QTY + '건</td>'+
        '<td class="text-primary text-right font-w600"'+
        'style="font-size: 90%; width: 80px;">'+numberWithCommas(product.PRODUCT_PRICE)+'원'+
        '</td>'+
        '</tr>';
    return content;

}

function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
