When dealing with SuperSim projects, you need to use the Java version 23. Use the following command to switch to the right version.

- `source "$HOME/.sdkman/bin/sdkman-init.sh" && sdk use java 23-oracle`

You shold always compile the project in the root module. When doing at the submodule level it will fail.

You should pass some parameters in order for the infrastructure module to not fail.

For your reference, this is the mvn command I use:
```
clean install -DskipTests -Dproject.config.infrastructure.build.phase=none -Dproject.config.infrastructure.deploy.phase=none -Dskip.npm -f pom.xml
```

- `-DskipTests` skips the tests.
- `-Dproject.config.infrastructure.build.phase=none` skips the build phase of the infrastructure module.
- `-Dproject.config.infrastructure.deploy.phase=none` skips the deploy phase of the infrastructure module.
- `-Dskip.npm` skips the npm install phase for the frontend.

When node version needs to be changed, use nvm command to change the version.

- `source $HOME/.nvm/nvm.sh && nvm use {version to use}`
