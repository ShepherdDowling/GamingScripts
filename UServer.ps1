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

UServer.ps1
    
    -Project   = Project Name (not required)
    -map       = Give a Map Name (as a Server)
    -IpAddress = Give an Server IP to connect to (as a Client)

    -game      = start as a client
    -server    = start as a server
    -editor    = Open the UE4 Editor 

    -second    = Open game on the second Screen
    -Third     = Open game on the third Screen

    -NoSteam   = Don't use Steam API

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

Invoke-Expression $core.CommandStr($map, $IpAddress, $NoSteam);

