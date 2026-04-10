When dealing with SuperSim projects, you need to use the Java version 23 and add a specific --settings parameter to the mvn comman:

- `sdk use java 23-oracle`
- `--settings=~/.m2/settings-supersim.xml`

You shold always compile the project in the root module. When doing at the submodule level it will fail.

When an error happens in the infrastructure module only, you can ignore it (it is a script private only for high permissioned people)

For your reference, this is the mvn command I use:
```
clean install -DskipTests -Dproject.config.infrastructure.build.phase=none -Dproject.config.infrastructure.deploy.phase=none -Dskip.npm -f pom.xml
```

The skip npm is for the portal applications where a ReactJS library is used for frontend and built with Maven.

If you decide to skip the spotless plugin, I think any version of Java will work.

`-Dspotless.apply.skip=true`
