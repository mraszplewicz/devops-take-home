# DevOps Take Home Exercise

## Repository content
- Folder with sample frontend application written in Angular
- Folder with sample backend microservice written in .NET Core 2, C#

The application is intended to show a list of recent security incidents

## Your Job
The purpose of this exercise is to demonstrate how to setup the infrastructure in a deployed Azure environment ​using code​. You can use whatever tools you want to do this (Chef, Puppet, Terraform, etc.). A few caveats for how the application should be deployed:
* Frontend is publicly available
* Backend service is a microservice that is called by frontend but is not publicly accessible
* AzureSQL database should not be publicly accessible

Don’t worry about fancy DNS for any parts of the application, accessing it via IP or Azure DNS is fine. Feel free to use Azure PaaS Services(e.g. App Services).

What we expect in your deliverable:
- All the needed links to the actual infrastructure
- All the needed links to your code

## Purpose of the Exercise
The purpose of the exercise is to understand how you approach the problem, the decisions you make in the infrastructure, and your ability to use code to accomplish things.

Please timebox your effort to 2 to 4 hours. An incomplete solution is not failing the exercise.

## Backend preparation
Download [.NET Core 2.x SDK](https://www.microsoft.com/net/download/windows) and run:
```
build.ps1
```

Optionally you can containerize backend application using Docker for Windows:
```
docker-build.ps1
```