use std::process::Command;

fn main() {
    // Assuming `pyapp` is the name of the embedded Python application
    let output = Command::new("./pyapp")
        .arg("--help")
        .output()
        .expect("Failed to execute pyapp command");

    if output.status.success() {
        println!("Successfully ran 'pyapp repo update'");
        println!("Output: {}", String::from_utf8_lossy(&output.stdout));
    } else {
        eprintln!("Error: {}", String::from_utf8_lossy(&output.stderr));
    }
}
