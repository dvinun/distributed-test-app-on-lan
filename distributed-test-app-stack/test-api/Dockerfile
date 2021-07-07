# BOF
FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /app
COPY *.csproj ./
EXPOSE 80
EXPOSE 443
# ENV ASPNETCORE_URLS=http://+:8080
RUN dotnet restore RESTTestApi.csproj
COPY . ./
RUN dotnet publish RESTTestApi.csproj -c Release -o out
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS runtime
WORKDIR /app
COPY --from=build /app/out .
ENTRYPOINT ["dotnet", "RESTTestApi.dll"]
# EOF