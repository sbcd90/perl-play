#!/usr/bin/perl
package Tasks::BuildWebappsWithMaven;

use warnings;
use strict;

use Exporter qw(import);
our @EXPORT = qw(execute setTomcatDirectory setMavenDirectory setMavenArtifactsDirectory setLocationsOfLocalDependencies setWebAppLoc setMavenSettingsFileLocation);

use File::Path;
use XML::Simple;
use Data::Dumper;
use File::Copy::Recursive qw(dircopy); 

#prefill default Locations
my $tomcatDir = "C:/Users/i076326/Documents/softwares/apache-tomcat-7.0.33/bin";
my $mavenDir = "C:/Users/i076326/Documents/softwares/apache-maven-3.0.5/bin";
my $mavenArtifactsDir = "C:/Users/i076326/.m2";
my @localDevVersions = ("C:/Users/i076326/git/sap.ui.m2m.extor.reuse");
my $webAppLoc = "C:/Users/i076326/git/ui.m2m.extor";
my $settingsFile = "settings-ui5.xml";

sub setTomcatDirectory{
    $tomcatDir = $_[0];
}

sub setMavenDirectory{
    $mavenDir = $_[0];
}

sub setMavenArtifactsDirectory{
    $mavenArtifactsDir = $_[0];
}

sub setLocationsOfLocalDependencies{
    @localDevVersions = @_;
}

sub setWebAppLoc{
    $webAppLoc = $_[0]; 
}

sub setMavenSettingsFileLocation{
    $settingsFile = $_[0];
}

sub execute{
    _stopTomcat();
    _cleanupTomcatDirectory();
    _readAndCleanupLocalDependencies();
    _createNewSnapshots();
    _hostAndStart();
}


sub _stopTomcat{
    chdir $tomcatDir;
    my @argsTomcatStop = ("shutdown.bat");
    system(@argsTomcatStop);
    
    print "Stop Tomcat\n";
}

sub _startTomcat{
    chdir $tomcatDir;
    my @argsTomcatStart = ("startup.bat");
    system(@argsTomcatStart);
}

sub _getArtifactIdOfParent{
    my $fileName = $webAppLoc . "/pom.xml";
    my $xml = new XML::Simple;
    
    my $data = $xml->XMLin($fileName);
    
    my $webappGroupId = $data->{groupId};
    my $webappArtifactId = $data->{artifactId};
    
    return $webappArtifactId;
}

sub _getWebappDirectory{
    my $tomcatPathMaker = substr($tomcatDir, 0, -4);
    $tomcatPathMaker = $tomcatPathMaker . "/webapps";
    
    return $tomcatPathMaker;
}

sub _cleanupTomcatDirectory{
    my $tomcatPathMaker = _getWebappDirectory();
    my $webappArtifactId = _getArtifactIdOfParent();
    rmtree($tomcatPathMaker . "/" . $webappArtifactId, { verbose => 1, mode => 0711 });
}

sub _readAndCleanupLocalDependencies{
    for my $count (@localDevVersions){
        my $fileName = $count . "/pom.xml";
        my $xml = new XML::Simple;
    
        my $data = $xml->XMLin($fileName);
    
        my $groupId = $data->{groupId};
        my $artifactId = $data->{artifactId};
    
        my @pathFormer = split('\.', $groupId);
        my $finalPath = $mavenArtifactsDir . "/repository";
        for my $pathCounter (@pathFormer) {
            $finalPath = $finalPath . "/" . $pathCounter;
        }
        $finalPath = $finalPath . "/" . $artifactId;
    
        #delete the snapshot tree under the maven directory
        rmtree($finalPath, { verbose => 1, mode => 0711 });
    
        print $!;
    }
}

sub _createNewSnapshots{
    #create new snapshots for each local dependency
    for my $count (@localDevVersions){
        my $dependencyName = $count;
    
        #assuming settings file resides in maven artifacts Dir
        my @mvnExecutorClean = ($mavenDir . "/mvn.bat","clean","-f",$dependencyName . "/pom.xml","--settings",$mavenArtifactsDir . "/" . $settingsFile);
        my @mvnExecutorInstall = ($mavenDir . "/mvn.bat","install","-f",$dependencyName . "/pom.xml","--settings",$mavenArtifactsDir . "/" . $settingsFile);
    
        system(@mvnExecutorClean);
        system(@mvnExecutorInstall);
    }

    #create new snapshot for webApp
    #assuming settings file resides in maven artifacts Dir
    my @mvnExecutorClean = ($mavenDir . "/mvn.bat","clean","-f",$webAppLoc . "/pom.xml","--settings",$mavenArtifactsDir . "/" . $settingsFile);
    my @mvnExecutorInstall = ($mavenDir . "/mvn.bat","install","-f",$webAppLoc . "/pom.xml","--settings",$mavenArtifactsDir . "/" . $settingsFile);

    system(@mvnExecutorClean);
    system(@mvnExecutorInstall);

}

sub _hostAndStart{
    #hosting webApp in tomcat
    
    my $tomcatPathMaker = _getWebappDirectory();
    my $webappArtifactId = _getArtifactIdOfParent();

    my @finalCmd = ("mkdir", $tomcatPathMaker . "/" . $webappArtifactId);
    system(@finalCmd);
    dircopy($webAppLoc . "/target/" . $webappArtifactId, $tomcatPathMaker . "/" . $webappArtifactId);
    _startTomcat();
}