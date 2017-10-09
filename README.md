## Rundeck-cli Docker Image

### Use rd-cli directly
- docker run -e RD_URL=http://rundeck:4440 -e RD_TOKEN=AFAKETOKENPLEASEREPLACE xirixiz/rundeck-cli rd <arg1> <arg2>

### Use a custom shell script (wrapper) around rd-cli
- docker run -e RD_URL=http://rundeck:4440 -e RD_TOKEN=AFAKETOKENPLEASEREPLACE xirixiz/rundeck-cli <script_name> <arg1> <arg2>

### Project job execution history purge/cleanup example included (rundeck cleanup):
- docker run -e RD_URL=http://rundeck:4440 -e RD_TOKEN=AFAKETOKENPLEASEREPLACE xirixiz/rundeck-cli projects_purge_execution_history --age 14d
