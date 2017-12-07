<%@ page pageEncoding="utf-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>오다 Map Demo</title>
    <link rel="stylesheet" type="text/css" href="../css/ordar-map.css">

</head>
<body>
<div class="row">
    <input type="text" placeholder="유사도 (0~5 // 전체 : -1)" id="similarity" />
    <input type="text" placeholder="가맹점갯수" id="cnt" />
    <input type="submit" id="getGroupListBtn">
</div>
<div id="map" style="width:100%;height:100%;"></div>

<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=5a368fb3bd2db850a7446547930d030d"></script>
<script src="http://code.jquery.com/jquery-latest.min.js"></script>
<script type="text/javascript" src="../js/classes.js"></script>
<script type="text/javascript" src="../js/ordar-map.js"></script>

</body>
</html>



