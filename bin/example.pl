#!/usr/bin/perl
use warnings;
use strict;

use File::Basename qw(dirname);
use Cwd  qw(abs_path);
use lib dirname(dirname abs_path $0) . '/lib';

use Tasks::BuildWebappsWithMaven;

my @inputDependencyList = ("C:/Users/i076326/Documents/Temporary/sap.ui.m2m.extor.reuse");
setLocationsOfLocalDependencies(@inputDependencyList);
execute();