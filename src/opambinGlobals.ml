(**************************************************************************)
(*                                                                        *)
(*    Copyright 2020 OCamlPro & Origin Labs                               *)
(*                                                                        *)
(*  All rights reserved. This file is distributed under the terms of the  *)
(*  GNU Lesser General Public License version 2.1, with the special       *)
(*  exception on linking described in the file LICENSE.                   *)
(*                                                                        *)
(**************************************************************************)

open EzFile.OP

let command = "opam-bin"
let version = "0.1.0"
let about =
  Printf.sprintf "%s %s by OCamlPro SAS <contact@ocamlpro.com>"
    command version

let home_dir = try Sys.getenv "HOME" with Not_found ->
  Printf.eprintf "Error: HOME variable not defined\n%!";
  exit 2


let opam_dir = try
    Sys.getenv "OPAMROOT"
  with Not_found -> home_dir // ".opam"

let opam_cache_dir = opam_dir // "download-cache"
let opam_repo_dir = opam_dir // "repo"
let opambin_dir = opam_dir // ( "_" ^ command )
let opambin_bin = opambin_dir // ( command ^ ".exe" )
let opambin_log = opambin_dir // ( command ^ ".log" )
let opambin_store_dir = opambin_dir // "store"
let opambin_cache_dir = opambin_dir // "cache"
let opambin_store_archives_dir = opambin_store_dir // "archives"
let opambin_store_repo_dir = opambin_store_dir // "repo"
let opambin_store_repo_packages_dir = opambin_store_repo_dir // "packages"

let opam_config_file = opam_dir // "config"
let opam_config_file_backup = opam_config_file ^ ".1"

let opam_switch_prefix =
  lazy (
    try
      Sys.getenv "OPAM_SWITCH_PREFIX"
    with Not_found ->
      Printf.eprintf
        "Error in %s: OPAM_SWITCH_PREFIX not defined.\n%!"
        command ;
      exit 2
  )
let opam_switch_prefix () = Lazy.force opam_switch_prefix

let opam_switch_dir = opam_switch_prefix
let opam_switch_internal_dir () =
  opam_switch_dir () // ".opam-switch"

let opam_switch_internal_config_dir () =
  opam_switch_internal_dir () // "config"

let opambin_switch_temp_dir () =
  opam_switch_internal_dir () // command

(* Where bin versions are stored to solve deps *)
let opambin_switch_packages_dir () =
  opam_switch_dir () // "etc" // command // "packages"


(* names of the files created in the package `files` sub-dir *)
let package_version = "bin-package.version"
let package_config = "bin-package.config"
let package_info = "bin-package.info"

let marker_cached = "_bincache"
let marker_source = "_binexec"

let config_file = opambin_dir // "config"

let curdir = Sys.getcwd ()

let system = "debian-buster-x86_64"


(*

File structure:

$HOME/.opam
   _opam-bin/
     opam-bin.exe
     opam-bin.log
     cache/
     store/
       archives/
       repo/
         packages/

$OPAM_SWITCH_PREFIX/
   etc/opam-bin/packages/$NAME

*)