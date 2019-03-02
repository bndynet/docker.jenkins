import jenkins.model.Jenkins
import java.util.logging.LogManager

/* Jenkins home directory */
def jenkinsHome = Jenkins.instance.getRootDir().absolutePath
def logger = LogManager.getLogManager().getLogger("")

System.setProperty("hudson.model.WorkspaceCleanupThread.disabled", "true")
logger.info("Jenkins Startup Script: Successfully updated the system properties. Script location: ${jenkinsHome}/init.groovy.d")