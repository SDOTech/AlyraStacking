import React, { Component } from "react";
import 'bootstrap/dist/css/bootstrap.min.css';
import getWeb3 from "./getWeb3";
import Button from 'react-bootstrap/Button';
import Card from 'react-bootstrap/Card';
import AlyraStakingContract from "./contracts/AlyraDaiStaking.json";
import "./App.css";



class App extends Component {

  state = { web3: null, accounts: null, contract: null };
  
  componentDidMount = async () => {    
    try {      
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts (Metamask).
      const accounts = await web3.eth.getAccounts();

      // get contract “AlyraStaking”
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = AlyraStakingContract.networks[networkId];
  
      const instance = new web3.eth.Contract(
        AlyraStakingContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ accounts, contract: instance, web3 }, this.runInit);
    } catch (error) {
        alert('Failed to load web3, accounts, or contract. Check console for details.');     
    }
  };
  

  runInit = async () => {
    try {

      const { contract } = this.state;

      //get contract infos      
      const sdoTokenAddr = await contract.methods.getSDOTokenAddress().call();

      // set contractInfo
      let contractInfo = {
        address:  contract._address,
        sdoTokenAddress : sdoTokenAddr
      }      
      this.setState({ contractInfo });

      //define account info
      this.setAccountInformation();
        
      window.ethereum.on('accountsChanged', (accounts) => this.handleAccountsChanged(accounts));      
    } catch (error) {      
      alert('Error in runInit');
    }
  }

  
  setAccountInformation = async () => {
    const { accounts } = this.state;    
        
    let accountInformation = {
      account: accounts[0]
    };
    this.setState({ accountInformation });    
  };

  
  //============================ Contract interact ===========================
  

  
  stake = async() => {
   //TODO
  }
 

  

  // ========== Handles events ==========

  // Account change on Wallet
  handleAccountsChanged = async(newAccounts) => {
    const { web3 } = this.state;
    const reloadedAccounts = await web3.eth.getAccounts();   
    this.setState({ accounts: reloadedAccounts });
    this.setAccountInformation();
  }
  
  // ==========  RENDER ==========
  
  render() {
    const {  accountInformation, contractInfo } = this.state;
    
    // === Define DIV sections ===

    //DIV User connection info 
    let divConnectionInfo = accountInformation ? 
      accountInformation.account + " ": 
      "Veuillez connecter un compte"
    
        

    return (
      <div className="App">
        <h1>STACKING DAPP</h1>
        <h2>ALYRA DEFI</h2>

         {/* Contract info */}
         <Card>
          <Card.Header>smart contract info</Card.Header>
          <Card.Body>            
            <Card.Text>
              Adresse du contrat :  {contractInfo ?  contractInfo.address: ""}          
            </Card.Text>            
            <Card.Text>
             SDOToken address : {contractInfo ?  contractInfo.sdoTokenAddress: ""}          
            </Card.Text>
          </Card.Body>
        </Card>

         {/* User Account Info */}
         <Card>
          <Card.Header>Utilisateur</Card.Header>
          <Card.Body>
            <Card.Title>{divConnectionInfo}</Card.Title>
            <Card.Text>
             ...
            </Card.Text>            
          </Card.Body>
        </Card>


      </div>
    );
  }
}

export default App;
