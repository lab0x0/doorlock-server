#!/usr/bin/env puma
environment     ENV['RACK_ENV'] || 'development'
daemonize       false
workers Integer(ENV['PUMA_WORKERS'] || 1)
threads Integer(ENV['MIN_THREADS'] || 0), Integer(ENV['MAX_THREADS'] || 16)
