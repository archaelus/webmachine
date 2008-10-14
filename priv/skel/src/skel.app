{application, skel,
 [{description, "skel"},
  {vsn, "0.1"},
  {modules, [
    skel,
    skel_app,
    skel_sup,
    skel_deps,
    skel_resource
  ]},
  {registered, [skel_sup]},
  {mod, {skel_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto, webmachine]}]}.
