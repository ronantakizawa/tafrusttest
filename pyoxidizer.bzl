def make_dist():
    return default_python_distribution(python_version="3.10")

def make_policy(dist):
    policy = dist.make_python_packaging_policy()
    policy.set_resource_handling_mode("files")
    policy.resources_location_fallback = "filesystem-relative:lib"
    policy.extension_module_filter = "no-copyleft"
    policy.bytecode_optimize_level_two = True
    return policy

def make_config(dist):
    config = dist.make_python_interpreter_config()
    config.run_command = "import subprocess; subprocess.run(['taf', '--help'], check=True)"  # Directly run the help command
    config.module_search_paths = ["$ORIGIN/lib"]
    return config

def make_exe(dist, policy, config):
    exe = dist.to_python_executable(
        name="taf",
        packaging_policy=policy,
        config=config,
    )
    exe.windows_runtime_dlls_mode = "always"
    exe.windows_subsystem = "console"

    # Include requirements and the root module.
    for resource in exe.pip_install(["-r", "requirements.txt"]):
        resource.add_location = "filesystem-relative:lib"
        exe.add_python_resource(resource)

    return exe

def make_embedded_resources(exe):
    return exe.to_embedded_resources()

def make_install(exe):
    files = FileManifest()
    files.add_python_resource(".", exe)
    return files

# Dynamically enable automatic code signing.
def register_code_signers():
    if not VARS.get("ENABLE_CODE_SIGNING"):
        return

# Call our function to set up automatic code signers.
register_code_signers()

register_target("dist", make_dist)
register_target("policy", make_policy, depends=["dist"], default=True)
register_target("config", make_config, depends=["dist"], default=True)
register_target("exe", make_exe, depends=["dist", "policy", "config"], default=True)
register_target("resources", make_embedded_resources, depends=["exe"], default_build_script=True)
register_target("install", make_install, depends=["exe"], default=True)
resolve_targets()
