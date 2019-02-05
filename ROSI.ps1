######################################################
# Draws the form
######################################################

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


function CurrentUser {
    $test = (Test-Connection -ComputerName $PCName -Count 1 -Quiet)
    if (-not $test) {
        continue
    }
    $User=Get-WMIObject -class Win32_ComputerSystem -ComputerName $PCName | Select-Object username
    $TextBox2.Text=$User.username
}

function BootTime {
    $Time = Get-WmiObject win32_operatingsystem -ComputerName $PCName | select csname, @{LABEL='LastBootUpTime'
    ;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
    $TextBox3.Text=$Time.lastbootuptime
}
function DiskSpace 
{
    $DiskPC = $TextBox1.Text
    $disk = Get-WmiObject Win32_LogicalDisk -ComputerName $DiskPC -Filter "DeviceID='C:'" |
    Select-Object Size,FreeSpace
    $size=[Math]::Round($disk.Size / 1GB)
    $free=[Math]::Round($disk.FreeSpace / 1GB)
    $TextBox4.Text = "$free out of $size GBs"
}

function DiskClean
{
    Start-Process Powershell "Remove-Item -Recurse -Verbose -Force -ErrorAction SilentlyContinue \\$PCName\C$\Windows\temp\*"
    Start-Process Powershell "Remove-Item -Recurse -Verbose -Force -ErrorAction SilentlyContinue \\$PCName\C$\Windows\ccmcache\*"
    Start-Process Powershell "Remove-Item -Recurse -Verbose -Force -ErrorAction SilentlyContinue '\\$PCName\C$\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*'"
    Start-Process Powershell "Remove-Item -Recurse -Verbose -Force -ErrorAction SilentlyContinue \\$PCName\C$\Users\*\AppData\Local\Microsoft\Windows\INetCache\*"
    Start-Process Powershell "Remove-Item -Recurse -Verbose -Force -ErrorAction SilentlyContinue '\\$PCName\C$\Users\*\AppData\Local\Google\Chrome\User Data\Default\Cache\*'"
    $TextBox5.AppendText("Cleaned temp files...`r`n")
    $TextBox5.AppendText("Cleaned SCCM cache...`r`n")
    $TextBox5.AppendText("Cleaned IE and Chrome cache...`r`n")
    $TextBox5.AppendText("Complete!")
}

function Ping {
   Start-Process Powershell "Test-Connection -ComputerName $PCName -Count 99"
}




#Main Form
$Form1                            = New-Object system.Windows.Forms.Form
$Form1.ClientSize                 = '350,500'
$Form1.text                       = "ROSI"
$Form1.TopMost                    = $false
$Form1.BackColor                  = "#404040"
$Icon                             = New-Object system.drawing.icon ("\\nfdvapp01\helpdesk\Software\ROSI\Resources\icon.ico")
$Form1.Icon                        = $Icon

#Computer Name Label
$Label1                          = New-Object system.Windows.Forms.Label
$Label1.text                     = "Computer Name:"
$Label1.AutoSize                 = $true
$Label1.width                    = 25
$Label1.height                   = 10
$Label1.location                 = New-Object System.Drawing.Point(10,50)
$Label1.Font                     = 'News Gothic MT,10'
$Label1.BackColor                = "#404040"
$Label1.ForeColor                = "#FFFFFF"

#System Info Label
$Label2                          = New-Object system.Windows.Forms.Label
$Label2.text                     = "-System Info-"
$Label2.AutoSize                 = $true
$Label2.width                    = 25
$Label2.height                   = 10
$Label2.location                 = New-Object System.Drawing.Point(12,86)
$Label2.Font                     = 'News Gothic MT,8'
$Label2.BackColor                = "#666666"
$Label2.ForeColor                = "#FFFFFF"

#Computer name text box
$TextBox1                        = New-Object system.Windows.Forms.TextBox
$TextBox1.multiline              = $false
$TextBox1.width                  = 160
$TextBox1.height                 = 32
$TextBox1.location               = New-Object System.Drawing.Point(130,48)
$TextBox1.Text                   = ""


#OK button
$Button1                         = New-Object system.Windows.Forms.Button
$Button1.text                    = "OK"
$Button1.width                   = 32
$Button1.height                  = 26
$Button1.location                = New-Object System.Drawing.Point(290,45)
$Button1.font                    = 'News Gothic MT,8'
$Button1.backColor                = "#FFFFFF"
$Button1.Add_Click({$PCName=$TextBox1.Text;CurrentUser;BootTime;DiskSpace})

#Disk clean button
$Button2                         = New-Object system.Windows.Forms.Button
$Button2.Text                    = "Clean Disk"
$Button2.Width                   = 100
$Button2.Height                  = 30
$Button2.Location                = New-Object System.Drawing.Point(126,320)
$Button2.Font                    = 'News Gothic MT,10'
$Button2.BackColor                = "#FFFFFF"
$Button2.Add_Click({$PCName=$TextBox1.Text;DiskClean})

#Ping button
$Button3                         = New-Object system.Windows.Forms.Button
$Button3.Text                    = "Ping PC"
$Button3.Width                   = 100
$Button3.Height                  = 30
$Button3.Location                = New-Object System.Drawing.Point(126,248)
$Button3.Font                    = 'News Gothic MT,10'
$Button3.BackColor                = "#FFFFFF"
$Button3.Add_Click({,$PCName=$TextBox1.Text;Ping})

#system Info Panel
$Panel1                          = New-Object system.Windows.Forms.Panel
$Panel1.height                   = 221
$Panel1.width                    = 332
$Panel1.BackColor                = "#666666"
$Panel1.location                 = New-Object System.Drawing.Point(9,85)

#Logged in user label
$Label3                          = New-Object system.Windows.Forms.Label
$Label3.text                     = "Currently Logged In:"
$Label3.AutoSize                 = $true
$Label3.width                    = 25
$Label3.height                   = 10
$Label3.location                 = New-Object System.Drawing.Point(16,120)
$Label3.Font                     = 'News Gothic MT,10'
$Label3.BackColor                = "#666666"
$Label3.ForeColor                = "#FFFFFF"

#Logged in user text box
$TextBox2                        = New-Object system.Windows.Forms.TextBox
$TextBox2.multiline              = $false
$TextBox2.width                  = 150
$TextBox2.height                 = 30
$TextBox2.location               = New-Object System.Drawing.Point(160,120)

#Last boot label
$Label4                          = New-Object system.Windows.Forms.Label
$Label4.text                     = "Last Boot Time:"
$Label4.AutoSize                 = $true
$Label4.width                    = 25
$Label4.height                   = 10
$Label4.location                 = New-Object System.Drawing.Point(16,160)
$Label4.Font                     = 'News Gothic MT,10'
$Label4.BackColor                = "#666666"
$Label4.ForeColor                = "#FFFFFF"

#Last boot text box
$TextBox3                        = New-Object system.Windows.Forms.TextBox
$TextBox3.multiline              = $false
$TextBox3.width                  = 150
$TextBox3.height                 = 30
$TextBox3.location               = New-Object System.Drawing.Point(160,160)

#Disk clean text box
$TextBox5                        = New-Object system.Windows.Forms.TextBox
$TextBox5.multiline              = $true
$TextBox5.width                  = 260
$TextBox5.height                 = 100
$TextBox5.location               = New-Object System.Drawing.Point(44,360)
$TextBox5.font                   = 'Microsoft Sans Serif,10'
$TextBox5.text                   = ""

#Disk free space label
$Label5                          = New-Object system.Windows.Forms.Label
$Label5.text                     = "Free Disk Space (GB):"
$Label5.AutoSize                 = $true
$Label5.width                    = 25
$Label5.height                   = 10
$Label5.location                 = New-Object System.Drawing.Point(16,200)
$Label5.Font                     = 'News Gothic MT,10'
$Label5.BackColor                = "#666666"
$Label5.ForeColor                = "#FFFFFF"

#Disk free space text box
$TextBox4                        = New-Object system.Windows.Forms.TextBox
$TextBox4.multiline              = $false
$TextBox4.width                  = 150
$TextBox4.height                 = 30
$TextBox4.location               = New-Object System.Drawing.Point(160,200)
$TextBox4.Text                   = ""

#Version info
$Label6                          = New-Object system.Windows.Forms.Label
$Label6.text                     = "version 0.2 @pku9624"
$Label6.AutoSize                 = $true
$Label6.width                    = 25
$Label6.height                   = 6
$Label6.location                 = New-Object System.Drawing.Point(270,490)
$Label6.Font                     = 'News Gothic MT,6'
$Label6.BackColor                = "#404040"
$Label6.ForeColor                = "#FFFFFF"

#Main Label
$Label7                          = New-Object system.Windows.Forms.Label
$Label7.text                     = "Rapid OS Information"
$Label7.AutoSize                 = $true
$Label7.width                    = 25
$Label7.height                   = 12
$Label7.location                 = New-Object System.Drawing.Point(78,10)
$Label7.Font                     = 'Georgia,12,style=Bold'
$Label7.BackColor                = "#404040"
$Label7.ForeColor                = "#FFFFFF"


$Form1.controls.AddRange(@($Label1,$Label2,$Label3,$Label4,$Label5,$Label6,$Label7,$TextBox1,$TextBox2,$TextBox3,$TextBox4,$TextBox5,$Button1,$Button2,$Button3,$Panel1))
[void]$Form1.ShowDialog()


$Global:PCName=$TextBox1.Text

