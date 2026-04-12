return {
  {
    "nvim-mini/mini.starter",
    version = "*",
    lazy = false,
    priority = 1000,
    opts = {
      header = [=[
.         .                                  .*%@@@@@%+.                               .            
     .                      .        .      +@@@#+=+%@@@=.  .       .                               
                  .                       .+@@%.     :@@@:     .                     .              
               .                          .%@@:       =@@*          . .      .                      
    .                      .              :@@@        :@@%              .                           
           .  .               .           :%@@.       :@@%  .             .     . .   .             
               . .       .                .#@@=.      -@@*              .  .                        
.     .    . .      .        .             :@@%:     .%@@-        ..                                
                    ..      ..  .           =@@%.   .#@@*.             ..       .        .          
.      .                .   =@@*-.           -@@@=.-@@@=          .:-#@@.              .            
                          . =@@@@@@@@*=-:::::::#@@@@@+:::::::-+#@@@@@@@@.                   .      .
                   .    .   =@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.                     .     
             .              =@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.        .                  
                            =@%*=:             =@@@@@:            .-+#%@.       .              .    
            .          .                .      =@@@@@:                                              
                                               =@@@@@:.             .                               
  ..              .                            =@@@@@:                     .    .       .           
                                 .             =@@@@@:                                          .   
.             .      .          .              =@@@@@:                 .   .                        
       .        .           .                  =@@@@@:                                           .  
         .                .                   .=@@@@@:                         ..                   
                                               =@@@@@:    .          .              .               
                                               =@@@@@: .                        ..                  
                       .     .                 =@@@@@:..    . .                                     
                .                    .  .   .  *@@@@@-            .   .                             
.                   . .                       .%@@@@@+                                              
                          .   .   .       .   :@@@@@@@.       .                                   . 
                                             .#@@@@@@@*.                 .                    .     
          .     .  .  .                 .   .+@@@@@@@@@-         .  .                         .     
.             .              .              -@@@@@@@@@@@:                                         . 
        ]=],
      footer = "welcome",
      items = {
        { name = "Edit new buffer", action = "enew", section = "Commands" },
        { name = "Terminal", action = "terminal", section = "Commands" },
        { name = "Files", action = "FzfLua files", section = "Files" },
        { name = "Recent Files", action = ":Telescope oldfiles", section = "Files" },
      },
      function()
        require("mini.starter").setup()
      end,
    },
  },
}
