@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!C:\Perl64\bin\perl.exe 
#line 15

=head1 NAME

autobuilds - Command line utility.

=cut

use warnings;
use strict;
use MavenBuilds::Tasks::BuildWebappsWithMaven;
MavenBuilds::Tasks::BuildWebappsWithMaven->setOptions;
MavenBuilds::Tasks::BuildWebappsWithMaven->execute;

=head1 SYNOPSIS

autobuilds [options]

Options:

    --tomcatDir=tomcatDir      TomcatDirectory(required)
    --mavenDir=mavenDir        MavenDirectory(required)
    --mavenArtifactsDir=mavenArtifactsDir      MavenArtifactsDirectory(required)
    --localDevVersions=localDevVersions        LocalDevArtifactsVersion(required)
    --webAppLoc=webAppLoc                      WebAppLocation(required)
    --settingsFile=settingsFile       MavenSettingsFile(required)

Example:

    autobuilds --tomcatDir=C:/Users/i076326/Documents/softwares/apache-tomcat-7.0.57/bin --mavenDir=C:/Users/i076326/Documents/softwares/apache-maven-3.0.5/bin              --mavenArtifactsDir=C:/Users/i076326/.m2 --localDevVersions=C:/Users/i076326/git/sap.ui.m2m.extor.reuse --webAppLoc=C:/Users/i076326/git/ui.m2m.extor                       --settingsFile=settings-ui5.xml

=head1 DESCRIPTION

Perl Module to build Maven webapps & host them with tomcat.

=head1 CONFIGURATION

Some configuration information.

NA

=cut
__END__
:endofperl
