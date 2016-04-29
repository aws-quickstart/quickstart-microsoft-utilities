param(
    $Name,
    $Password
)

$cn = [ADSI]"WinNT://$($env:COMPUTERNAME)"
$user = $cn.Create("User", $Name)
$user.SetPassword($Password)
$user.setinfo()
$user.description = "Local administrator"
$user.SetInfo()

$adminGroup = [ADSI]"WinNT://$($env:COMPUTERNAME)/administrators, group"
$adminGroup.Add($user.Path)