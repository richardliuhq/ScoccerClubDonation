# ScoccerClubDonation
My Ethereum Solidify sample works - Donate a soccer team

Demo environment description:
  Geth - one miner is running with command as: miner.start(1)
  Remix - Check scoccer team contract balances and others
  Browser - Add new scoccer team and get the generated team contract address
  MetaMask
  ...
  
Demo script:
Start Geth at private network
Start miner
Open browser and add a new scoccer team (Team name, coach name and players)
Submit the team creation transaction at MetaMask
After the miner running, a new contract will be created for that scoccer team
The team contract address will show up at browser
Get the team contract address from team table,send 6999 wei to the team  at the MetaMask and submit the transaction
Open remix and open the team contract via its contract address
Verify the team balance is 6999 via function -  getBalance()
Leave remis open and transfer another 10000 wei to the team
After the miner running, verify the new balance at Remix
Verify if balance autit passed via the function: is AuditPassed

Demo URL: 
https://youtu.be/0KoO12WHuUw



  
  
  
  

