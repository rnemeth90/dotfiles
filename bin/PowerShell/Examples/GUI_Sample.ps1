Add-Type -AssemblyName System.Windows.Forms

$TestForm = New-Object system.Windows.Forms.Form
$TestForm.Text = "Test Form"
$TestForm.BackColor = "#723535"
$TestForm.TopMost = $true
$TestForm.Width = 640
$TestForm.Height = 432

$button2 = New-Object system.windows.Forms.Button
$button2.Text = "button"
$button2.Width = 60
$button2.Height = 30
$button2.location = new-object system.drawing.point(265,263)
$button2.Font = "Microsoft Sans Serif,10"
$TestForm.controls.Add($button2)

$button2 = New-Object system.windows.Forms.Button
$button2.Text = "button"
$button2.Width = 60
$button2.Height = 30
$button2.location = new-object system.drawing.point(265,263)
$button2.Font = "Microsoft Sans Serif,10"
$TestForm.controls.Add($button2)

$textBox12 = New-Object system.windows.Forms.TextBox
$textBox12.Width = 100
$textBox12.Height = 20
$textBox12.Add_Click({
#add here code triggered by the event
})
$textBox12.location = new-object system.drawing.point(10,20)
$textBox12.Font = "Microsoft Sans Serif,10"
$TestForm.controls.Add($textBox12)

$textBox12 = New-Object system.windows.Forms.TextBox
$textBox12.Width = 100
$textBox12.Height = 20
$textBox12.Add_Click({
#add here code triggered by the event
})
$textBox12.location = new-object system.drawing.point(10,20)
$textBox12.Font = "Microsoft Sans Serif,10"
$TestForm.controls.Add($textBox12)

[void]$TestForm.ShowDialog()
$TestForm.Dispose()