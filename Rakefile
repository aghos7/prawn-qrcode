# Copyright 2011 Jens Hausherr
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

require 'rake'
require "rubygems"
require "rubygems/package_task"

spec = Gem::Specification.load "prawn-qrcode.gemspec"
Gem::PackageTask.new(spec).define do |pkg|
  #pkg.need_zip = true
  pkg.need_tar = true
end

task :default => :package

task :clean => :clobber_package
