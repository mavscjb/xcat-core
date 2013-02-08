Dim filesys, srcfile, srcfilename, fline,  dstfilename, dstfile, myshell, netuse
Dim tmpstr, elems
Set myshell = WScript.createObject("WScript.Shell")
Set netuse = myshell.Exec("net use")
Dim drvletter
Do While Not netuse.StdOut.AtEndOfStream
	tmpstr = netuse.StdOut.ReadLine()
	if InStr(tmpstr,"install") > 0 Then
		Do while InStr(tmpstr,"  ") > 0
			tmpstr = Replace(tmpstr,"  "," ")
		Loop
		elems = Split(tmpstr)
		drvletter=elems(1)
	End If
Loop
	
Set filesys = CreateObject("Scripting.FileSystemObject")
dim notefi
notefi=1
if filesys.FileExists(drvletter&"\utils\windows\detectefi.exe") then
	notefi = myshell.run(drvletter&"\utils\windows\detectefi.exe",1,true)
	WScript.Echo(notefi)
end if
WScript.Echo(notefi)
srcfilename = WScript.Arguments.Item(0)
dstfilename = WScript.Arguments.Item(1)
Set srcfile = filesys.OpenTextFile(srcfilename,1)
Set dstfile = filesys.OpenTextFile(dstfilename,2,True)
dim partitionscheme
Do Until srcfile.AtEndOfStream
        fline = srcfile.ReadLine
	if notefi=0 then
		fline = Replace(fline,"==BOOTPARTITIONS==","<CreatePartitions><CreatePartition><Order>1</Order><Type>EFI</Type><Size>260</Size></CreatePartition><CreatePartition><Order>2</Order><Type>MSR</Type><Size>128</Size></CreatePartition><CreatePartition><Order>3</Order><Type>Primary</Type><Extend>true</Extend></CreatePartition></CreatePartitions>")
		fline = Replace(fline,"==INSTALLTOPART==","3")
	else
		fline = Replace(fline,"==BOOTPARTITIONS==","<CreatePartitions><CreatePartition><Order>1</Order><Type>Primary</Type><Extend>true</Extend></CreatePartition></CreatePartitions>")
		fline = Replace(fline,"==INSTALLTOPART==","1")
	end if
	fline = Replace(fline,"==INSTALLTODISK==","0")
        dstfile.WriteLine(Replace(fline,"==INSTALLSHARE==",drvletter))
Loop