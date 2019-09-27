# author: Orlando Rocha
# email: ornrocha@gmail.com

$ProgressPreference = 'SilentlyContinue'
$minicondadir = 'C:\Users\'+$env:username+'\Miniconda3'


# This function is from https://scatteredcode.net/download-and-extract-gzip-tar-with-powershell/
Function DeGZip-File{
    Param(
        $infile,
        $outfile = ($infile -replace '\.gz$','')
        )
    $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
    $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)
    $buffer = New-Object byte[](1024)
    while($true){
        $read = $gzipstream.Read($buffer, 0, 1024)
        if ($read -le 0){break}
        $output.Write($buffer, 0, $read)
        }
    $gzipStream.Close()
    $output.Close()
    $input.Close()
}

function check_if_installed($p1){

$software = $p1;
$installed = ((gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match $p1).Length -gt 0

If(-Not $installed) {
	Write-Host "'$software'  is not installed.";
} else {
	Write-Host "'$software' is installed."
}
 return $installed

}


function installscala(){

$scala = check_if_installed -p1 "Scala"

   if(-Not $scala){
       Write-Host 'Downloading Scala 2.11.12...'
	   Invoke-WebRequest https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.msi -OutFile "$env:TEMP\scala-2.11.12.msi"
	   $TemptFiles += "$env:TEMP\scala-2.11.12.msi"
	   Write-Host 'Installing Scala 2.11.12...'
	   Start-Process msiexec.exe -Wait -ArgumentList "/I `"$env:TEMP\scala-2.11.12.msi`" "
   }
   else{
   
    Write-Host 'Scala is already installed'
   
   }
}

function installmaven(){

$tempArchive = "$env:TEMP\apache-maven-3.6.2-bin"

Write-Host "Downloading Maven..."
Invoke-WebRequest -Uri https://archive.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.zip -OutFile "$($tempArchive).zip"


Write-Host "Decompressing archive..."

if (-not (Get-Command Expand-7Zip -ErrorAction Ignore)) {
     Install-Package -Scope CurrentUser -Force 7Zip4PowerShell > $null
    }
	
Expand-7Zip "$($tempArchive).zip" "$env:TEMP\apache-maven-3.6.2-bin"

Copy-Item -Path "$($tempArchive)\apache-maven-3.6.2" -Destination C:\bin\maven -recurse -Force
Write-Host "Maven installation is complete." -ForegroundColor Green

}


function installjava(){

$java = (Get-Command java | Select-Object -ExpandProperty Version).Length -gt 0

   if(-Not $java){
       Write-Host "Java is not installed.";
       Write-Host 'Downloading Java... '
	   Invoke-WebRequest https://download.bell-sw.com/java/8u222/bellsoft-jdk8u222-windows-amd64.msi -OutFile "$env:TEMP\bellsoft-jdk8u222-windows-amd64.msi"
	   $TemptFiles += "$env:TEMP\bellsoft-jdk8u222-windows-amd64.msi"
	   Write-Host 'Installing Java jdk8u222...'
	   Start-Process msiexec.exe -Wait -ArgumentList "/I `"$env:TEMP\bellsoft-jdk8u222-windows-amd64.msi`" "
	   Write-Host "Java installation is complete." -ForegroundColor Green

   }
   else{
   
    Write-Host 'Java is already installed'
   
   }
}


function installminiconda(){

#$passinstall=$true
Write-Host $minicondadir
if(!(Test-Path -Path $minicondadir )){
	Write-Host "Miniconda3 is not installed.";
    Write-Host 'Downloading Miniconda3... '
    Invoke-WebRequest https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe -OutFile "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"
    $TemptFiles += "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe"
    Write-Host 'Installing Miniconda3...'
	Start-Process -Wait -FilePath "$env:TEMP\Miniconda3-latest-Windows-x86_64.exe" -ArgumentList "/S /D=$($minicondadir)" -PassThru
	#$passinstall=$false
	Write-Host "Miniconda installation is complete." -ForegroundColor Green
	
}
else{
    Write-Host "Miniconda3 already exists"
}

Write-Host "Configuring conda environment for Spark..."

Set-Location "$($minicondadir)\condabin"
cmd /k "conda create -n sparkenv python=3.6 & exit"

Set-Location "$($minicondadir)\condabin"
cmd /k "activate sparkenv & conda install jupyter seaborn pandas scikit-learn & exit"
#Set-Location "C:\Users\or\Documents"

Write-Host "Configuration is complete." -ForegroundColor Green

}

function installhadoopwinutils(){


$tempArchive = "$env:TEMP\hadoop-winutils"

Write-Host "Downloading Hadoop Winutils..."
Invoke-WebRequest -Uri https://github.com/steveloughran/winutils/archive/master.zip -OutFile "$($tempArchive).zip"


Write-Host "Decompressing archive..."

if (-not (Get-Command Expand-7Zip -ErrorAction Ignore)) {
     Install-Package -Scope CurrentUser -Force 7Zip4PowerShell > $null
    }
	
Expand-7Zip "$($tempArchive).zip" "$env:TEMP\tmp-hadoop-winutils"

Copy-Item -Path "$env:TEMP\tmp-hadoop-winutils\winutils-master\hadoop-2.7.1" -Destination C:\bin\hadoop -recurse -Force
Write-Host "Hadoop installation is complete." -ForegroundColor Green

}

function installspark(){

$tempArchive = "$env:TEMP\spark-2.4.3-bin-hadoop2.7"

Write-Host "Downloading Spark 2.4.3..."
Invoke-WebRequest -Uri https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz -OutFile "$($tempArchive).tgz"
$TemptFiles += "$($tempArchive).tar"

Write-Host "Decompressing archive..."

DeGZip-File "$($tempArchive).tgz" "$($tempArchive).tar"


if (-not (Get-Command Expand-7Zip -ErrorAction Ignore)) {
     Install-Package -Scope CurrentUser -Force 7Zip4PowerShell > $null
    }
	
Expand-7Zip "$($tempArchive).tar" "C:\bin"
Rename-Item C:\bin\spark-2.4.3-bin-hadoop2.7 C:\bin\spark
Write-Host "Spark installation is complete." -ForegroundColor Green

}

#[System.EnvironmentVariableTarget]::Machine
function setenvvars(){
Write-Host "Setting environment variables..."
[System.Environment]::SetEnvironmentVariable('MAVEN_HOME', "C:\bin\maven", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('HADOOP_HOME', "C:\bin\hadoop", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('SPARK_HOME', "C:\bin\spark\", [System.EnvironmentVariableTarget]::User)

$path = [Environment]::GetEnvironmentVariable("PATH","User")
$pythonpath = [Environment]::GetEnvironmentVariable("PYTHONPATH")

   $answer = $null;

	while(@('y', 'n') -notcontains $answer) {
		$answer = (Read-Host "Do you want to add conda to Windows path? [y/n]").ToLower();
	}
 
	if ($answer -eq 'y') {
	  [System.Environment]::SetEnvironmentVariable('Path', $path+";C:\bin\maven\bin;C:\bin\spark\bin;C:\bin\hadoop\bin;$($minicondadir);$($minicondadir)\Scripts;$($minicondadir)\Library\bin", [System.EnvironmentVariableTarget]::User)
	}
	else{
	  [System.Environment]::SetEnvironmentVariable('Path', $path+";C:\bin\maven\bin;C:\bin\spark\bin;C:\bin\hadoop\bin", [System.EnvironmentVariableTarget]::User)
	}

[System.Environment]::SetEnvironmentVariable('PYSPARK_LIBS', "C:\bin\spark\python\lib\pyspark.zip", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('PYSPARK_PYTHON',"$($minicondadir)\envs\sparkenv\python.exe", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable('PYTHONPATH' ,"C:\bin\spark\python;C:\bin\spark\python\lib\py4j-0.10.7-src.zip;"+$pythonpath, [System.EnvironmentVariableTarget]::User)
Write-Host "Settings are complete." -ForegroundColor Green

}

# not working at this moment
function setupkernels(){

   $answer = $null;

	while(@('y', 'n') -notcontains $answer) {
		$answer = (Read-Host "Do you want to install Spark kernels on jupyter? [y/n]").ToLower();
	}

	if ($answer -eq 'y') {
	
	    Write-Host "Configuring Spark kernels for Jupyter..." 
		
		$tempArchive = "$env:TEMP\RefreshEnv.cmd"


        Invoke-WebRequest -Uri https://github.com/chocolatey/choco/raw/master/src/chocolatey.resources/redirects/RefreshEnv.cmd -OutFile "$($tempArchive)"
		Set-Location "$env:TEMP"
		cmd /k "RefreshEnv & exit"

		Set-Location "$($minicondadir)\condabin"
		cmd /k "activate sparkenv & pip install toree & jupyter toree install --spark_home c:/bin/spark --kernel_name='Toree' --interpreters=Scala,SQL --user & exit"
		#cmd /k "activate sparkenv & pip uninstall toree & exit"
		#cmd /k "activate sparkenv & pip install toree==0.2.0 & jupyter toree install --spark_home c:/bin/spark --kernel_name='Toree' --interpreters=PySpark,Scala,SQL --user & exit"
		#Set-Location "C:\Users\or\Documents"
		
		Write-Host "Kernels installation is complete." -ForegroundColor Green
	}
	else{
	    Write-Host "The installation of Spark kernels has been canceled." -ForegroundColor Green
	}

}


installscala
installjava
installmaven
installminiconda
installhadoopwinutils
installspark
setenvvars
Write-Host "Spark installation is finished." -ForegroundColor Green
#setupkernels