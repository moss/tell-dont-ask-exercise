#!/bin/bash
ls spec/*_spec.rb | xargs -n1 rspec
