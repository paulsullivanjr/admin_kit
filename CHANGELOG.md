# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-21

### Added

- Initial release
- Resource DSL macro for defining admin resources
- Context-first architecture — no direct Repo access
- Built-in field types: string, integer, boolean, datetime, date, select, multi_select, image, rich_text, json_viewer, belongs_to, has_many
- Authorization via `AdminKit.Policy` behaviour
- LiveView-native UI: index, show, new/edit forms, dashboard
- Search, sorting, and pagination
- Custom actions (member and collection scope)
- Named filter scopes
- Telemetry instrumentation
- Router macro `live_admin/3`
