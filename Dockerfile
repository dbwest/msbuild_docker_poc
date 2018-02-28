FROM compulim/msbuild
SHELL ["powershell"]

#Add iis
RUN Add-WindowsFeature Web-Server

# Install .Net Core SDK
# ENV DOTNET_SDK_VERSION 1.0.0-preview2-003131
# ENV DOTNET_SDK_DOWNLOAD_URL https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/$DOTNET_SDK_VERSION/dotnet-dev-win-x64.$DOTNET_SDK_VERSION.zip
# RUN powershell -NoProfile -Command $ErrorActionPreference = 'Stop'; \ 
# Invoke-WebRequest https://dotnetcli.blob.core.windows.net/dotnet/preview/Binaries/1.0.0-preview2-003131/dotnet-dev-win-x64.1.0.0-preview2-003131.zip -OutFile dotnet.zip; \
# Expand-Archive dotnet.zip -DestinationPath '%ProgramFiles%\dotnet'; \ 
# Remove-Item -Force dotnet.zip
# RUN setx /M PATH "%PATH%;%ProgramFiles%\dotnet"

# # Trigger the population of the local package cache
# ENV NUGET_XMLDOC_MODE skip
# RUN mkdir warmup \
# && cd warmup \
# && dotnet new \
# && cd .. \
# && rmdir /q/s warmup

# RUN Install-WindowsFeature NET-Framework-45-ASPNET
# RUN Install-WindowsFeature NET-Framework-45-FEATURES
# RUN Install-WindowsFeature Web-Asp-Net45

#note: framework must match exactly
RUN Invoke-WebRequest "https://download.microsoft.com/download/1/6/7/167F0D79-9317-48AE-AEDB-17120579F8E2/NDP451-KB2858728-x86-x64-AllOS-ENU.exe" -OutFile "$env:TEMP\net451.exe" -UseBasicParsing
RUN & "$env:TEMP\net451.exe" /q

RUN Invoke-WebRequest "https://download.microsoft.com/download/9/6/0/96075294-6820-4F01-924A-474E0023E407/NDP451-KB2861696-x86-x64-DevPack.exe" -OutFile "$env:TEMP\devpack451.exe" -UseBasicParsing
RUN & "$env:TEMP\devpack451.exe" /q

COPY . 'C:\\build\\'
WORKDIR 'C:\\build\\'

RUN ["nuget.exe", "restore"]
RUN ["nuget.exe", "Install MSBuild.Microsoft.VisualStudio.Web.targets"]
RUN ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2017\\BuildTools\\MSBuild\\15.0\\Bin\\MSBuild.exe", "C:\\build\\GuidGenerator.sln"]