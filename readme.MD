1.  userdata should have 
        #!/bin/bash
    or commands will not work

2.  ports should be allowed in security group or you will not be able to access any servers running on the instance

3. updating userdata does not work. You need to delete stack and create new stack to change userdata