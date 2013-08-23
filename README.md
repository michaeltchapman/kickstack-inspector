Kickstack Inspector
===================

Project for inspecting which kickstack class parameters are being taken from where

## Install and Config

Install puppet and all kickstack modules and dependencies

Set logging to off in hiera.yaml

  :logger:
    - noop

## Usage

ruby resources.rb
