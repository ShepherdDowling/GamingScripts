param (
    [string] $project, # this is only here so it assumes the first arg
    [string] $map,
    [string] $IpAddress,

    [switch] $second,
    [switch] $third,

    [switch] $game,
    [switch] $server,
    [switch] $editor,

    [switch] $NoSteam,

    [switch] $help
)

if($help -eq $true)
{
    write-host "

UServer.ps1 .\PuzzelPlatforms.uproject -game
C:\AID\UE4\UE_4.25\Engine\Binaries\Win64\UE4Editor.exe D:\APD\UE4\Lessons\GDTV\Multiplayer\PuzzlePlatforms\PuzzelPlatforms.uproject   -game -log

UServer.ps1 .\PuzzelPlatforms.uproject -IpAddress 192.168.0.147 -game -third -map .\Content\Levels\Maps\PuzzelPlatforms.umap
C:\AID\UE4\UE_4.25\Engine\Binaries\Win64\UE4Editor.exe D:\APD\UE4\Lessons\GDTV\Multiplayer\PuzzlePlatforms\PuzzelPlatforms.uproject 192.168.0.147:7777 /Game/Levels/Maps/Pu
zzelPlatforms -game -log -WinX=3840 -WinY=1 -SAVEWINPOS=2

If the second one is the server, you must connect maually via the in-game prompt
else swap -game for -server

    "
    return;
}


class Core
{
    [string] $mode;
    [string] $editor;
    [string] $uproject;
    [string] $display;

    Core([string] $game, [string] $server, [string] $editor,
         [switch] $second, [switch] $third
    ){

        if ($game -eq $false -and $server -eq $false -and $editor -eq $false)
        {
            Write-Host "You must select a Game or Server Mode!"
            exit
        }elseif($game -eq $true) # The "-eq $true" is required
        {
            $this.mode = "-game"

            if($second -eq $true)
            {
                $this.display = "-WinX=1920 -WinY=0 -SAVEWINPOS=1"
            }elseif($third -eq $true){
                $this.display = "-WinX=3840 -WinY=1 -SAVEWINPOS=2"
            }

        }elseif($server -eq $true)
        {
            $this.mode = "-server"
        }# UE4E's default is the editor

        $this.editor = $(Get-Command UE4Editor.exe).path;
        $this.uproject = "$($PWD.Path)\$($(Get-ChildItem | Select-Object Name | Where-Object Name -like *uproject).Name)";
    }

    [string] CommandStr([string] $map, [string] $IpAddress, [bool] $NoSteam)
    {
        if($map.Length -gt 0 -and `
            [Regex]::new("^\.[/\\]Content.*$").Matches($(".\sContent\_Levels\Maps\ThirdPersonExampleMap.umap")))
        {
            $map = $map -replace "\\", "/" -replace "./Content", "/Game" -replace ".umap", ""
        }


        if ($this.mode -eq "-server" -and $map.Length -gt 0)
        {
            $map = $map + "?Listen"
        }

        if($IpAddress.Length -gt 0)
        {
            $IpAddress += ":7777"
        }

        $NetworkOption = ""
        if($NoSteam -eq $true)
        {
            $NetworkOption = " -nosteam"
        }


        $execution = $this.editor + " " + $this.uproject + " " +  $IpAddress + " " + $map  + " " + $this.mode + " -log " + $this.display + $NetworkOption
        Write-Host $execution;
        return $execution;
    }
}

$core = [Core]::new($game, $server, $editor, $second, $third);

#$core.CommandStr($map, $IpAddress) | out-null;
Invoke-Expression $core.CommandStr($map, $IpAddress, $NoSteam);

