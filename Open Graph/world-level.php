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

$worldname = "";
switch($_REQUEST['og:world'])
{
  case 1:
  $worldname = "HELL";
  break;

case 2:
  $worldname = "UNDERGROUND";
  break;

  case 3:
  $worldname = "OCEAN";
  break;

  case 4:
  $worldname = "LAND";
  break;
}
?>

<html>
      <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# wickeddevil: http://ogp.me/ns/fb/wickeddevil#">
      <meta property="fb:app_id" content="292930497469007" /> 
      <meta property="og:type"   content="wickeddevil:level" /> 
      <meta property="og:url" content="<?php echo strip_tags(curPageURL());?>">
      <meta property="og:title"  content="<?php echo $worldname;?>: Level <?php echo strip_tags($_REQUEST['og:level']);?>" /> 
       <meta property="og:description" content="Scored <?php echo strip_tags($_REQUEST['og:score']);?> and collected  <?php echo strip_tags($_REQUEST['og:bigsouls']);?> big souls!"/>
      <meta property="og:image"  content="http://www.wickedlittlegames.com/opengraph/wickeddevil/achievement.png" /> 
      <title>Wicked Devil - <?php echo $worldname;?>: Level <?php echo strip_tags($_REQUEST['og:level']);?>!</title>
  </head>
    <body>
        <p>Wicked Devil - World <?php echo $worldname;?>: Level <?php echo strip_tags($_REQUEST['og:level']);?>!</p>
        <p>Scored <?php echo strip_tags($_REQUEST['og:score']);?> and collected  <?php echo strip_tags($_REQUEST['og:bigsouls']);?> big souls!</p>
    </body>
</html>