<?php
function curPageURL() {
 $pageURL = 'http://';
 if ($_SERVER["SERVER_PORT"] != "80") {
  $pageURL .= $_SERVER["SERVER_NAME"].":".$_SERVER["SERVER_PORT"].$_SERVER["REQUEST_URI"];
 } else {
  $pageURL .= $_SERVER["SERVER_NAME"].$_SERVER["REQUEST_URI"];
 }
 return $pageURL;
}
?>

<html>
      <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# wickeddevil: http://ogp.me/ns/fb/wickeddevil#">
      <meta property="fb:app_id" content="292930497469007" /> 
      <meta property="og:type"   content="wickeddevil:level" /> 
      <meta property="og:url" content="<?php echo strip_tags(curPageURL());?>">
      <meta property="og:title"  content="World <?php echo strip_tags($_REQUEST['og:world']);?> Level <?php echo strip_tags($_REQUEST['og:level']);?>" /> 
      <meta property="og:image"  content="http://www.wickedlittlegames.com/opengraph/wickeddevil/achievement.png" /> 
      <title>Wicked Devil - World <?php echo strip_tags($_REQUEST['og:world']);?> Level <?php echo strip_tags($_REQUEST['og:level']);?>!</title>
  </head>
    <body>
        <p>Wicked Devil - World <?php echo strip_tags($_REQUEST['og:world']);?> Level <?php echo strip_tags($_REQUEST['og:level']);?>!</p>
    </body>
</html>