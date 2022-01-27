import React, { Component } from "react";
import 'bootstrap/dist/css/bootstrap.min.css';
import getWeb3 from "./getWeb3";

import Button from 'react-bootstrap/Button';
import Form from 'react-bootstrap/Form';
import Card from 'react-bootstrap/Card';
import CardGroup from 'react-bootstrap/CardGroup';
import Accordion from 'react-bootstrap/Accordion';
import Dialog from 'react-bootstrap-dialog';

import AlyraStakingContract from "./contracts/AlyraStaking.json";
import DaiContract from "./contracts/Dai.json";
import "./App.css";



class App extends Component {

  state = { web3: null, accounts: null, contract: null, contractDai:null };

  constructor () {
    super()
    this.confirmStake = this.confirmStake.bind(this)
  }
  
  componentDidMount = async () => {    
    try {      
      // Get network provider and web3 instance.
      const web3 = await getWeb3();

      // Use web3 to get the user's accounts (Metamask).
      const accounts = await web3.eth.getAccounts(); 

      // get contract “AlyraStaking”
      const networkId = await web3.eth.net.getId();
      const deployedNetwork = AlyraStakingContract.networks[networkId];

      //get contract "DaiContract"
      const networkIdDai = await web3.eth.net.getId();
      const deployedNetworkDai = DaiContract.networks[networkIdDai];
  
      const instance = new web3.eth.Contract(
        AlyraStakingContract.abi,
        deployedNetwork && deployedNetwork.address,
      );

      const instanceDai = new web3.eth.Contract(
        DaiContract.abi,
        deployedNetworkDai && deployedNetworkDai.address,
      );

      // Set web3, accounts, and contract to the state, and then proceed with an
      // example of interacting with the contract's methods.
      this.setState({ accounts, contract: instance, contractDai: instanceDai,web3 }, this.runInit);
    } catch (error) {
        alert('Failed to load web3, accounts, or contract. Check console for details.');     
    }
  };
  

  runInit = async () => {
    try {

      const { contract,  contractDai} = this.state;

      //get contract infos      
      const sdoTokenAddr = await contract.methods.getSDOTokenAddress().call();

      // set contractInfo
      let contractInfo = {
        address:  contract._address,
        sdoTokenAddress: sdoTokenAddr,
        daiAddress: contractDai._address
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
    
    const { accounts, contract, contractDai } = this.state;  

    const amount = await contract.methods.getUserBalance(accounts[0], contractDai._address).call();
    
    let accountInformation = {
      account: accounts[0],      
      daiStackedAmount: amount
    };


    this.setState({ accountInformation });    
  };

  //============================ UI functions ===========================
  confirmStake = async () => {
    try {      
      this.dialog.show({
        title: 'Stacker',
        body: 'Confirmez-vous le stacking ?',
        actions: [
          Dialog.CancelAction(),
          Dialog.OKAction(() => {           
            this.stackeIt();
          })
        ],
        bsSize: 'small',
        onHide: (dialog) => {
          dialog.hide()        
        }
      })      
      }catch (error) {
        alert(error, "ERREUR");
      }
    }

  
  //============================ Contract interact ===========================
  
  approveIt = async () => {
    try {    

      const { accounts, contract, contractDai } = this.state;
      const stckAmount = this.amountToStake.value;

      await contractDai.methods.approve(contract._address, stckAmount).send({ from: accounts[0] }).then(response => {
        alert('Approve OK');
      });

    }catch (error) {
      alert(error, "ERREUR");
    }    
  }
  
  stackeIt = async () => {
    try {
      const { accounts, contract } = this.state;

      const tokenAddress = this.tokenAddress.value;
      const stckAmount = this.amountToStake.value;
      
       await contract.methods.stakeToken(tokenAddress, stckAmount).send({ from: accounts[0] }).then(response => {          
         this.setAccountInformation();
        });   
    } catch (error) {
      alert(error, "ERREUR"); 
    }
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
    
    //DIV Contract Info
    let divContractInfo =
 
          <Card border="primary" style={{ maxWidth: '30rem' }}>          
          <Card.Body>            
            <Card.Text>
              Adresse du contrat :  {contractInfo ?  contractInfo.address: ""}          
            </Card.Text>  
            <Card.Text>
             tDAI address : {contractInfo ?  contractInfo.daiAddress: ""}          
            </Card.Text>
            <Card.Text>
             SDOToken address : {contractInfo ?  contractInfo.sdoTokenAddress: ""}          
            </Card.Text>
          </Card.Body>
        </Card>
    
    //DIV User Info
    let divUserInfo = 
    <Card border="primary" style={{ maxWidth: '30rem' }}> 
    <Card.Header>Utilisateur</Card.Header>
    <Card.Body>           
      <Card.Text>
       DAI stackés : {accountInformation ? accountInformation.daiStackedAmount : ""}
      </Card.Text>   
      <Card.Text>
       Récompense (SDO) : 
      </Card.Text>  
    </Card.Body>
    </Card>
           
    
    //DIV Stake
    let divStake =    
      <Card border="primary" style={{ maxWidth: '30rem' }}> 
         <Card.Header>tDAI</Card.Header>
        <Form> 
          <Form.Group>
              {/* <Form.Control type="text" id="tokenAddress" placeholder="adresse token"  ref={(input) => { this.tokenAddress = input }} />           */}
                        
              <Card.Body>
                
                <Card.Text>
                Entrez ici le montant de tDAI à stacker, puis approuver avant de Stacker.
                    <Form.Control type="text" id="amountToStake" placeholder="Montant" ref={(input) => { this.amountToStake = input }} />     
                </Card.Text>                
                  <Button onClick={this.approveIt} >Approuver</Button> {' '} 
                  <Button onClick={this.confirmStake} >Stacker</Button>
              </Card.Body>
                     
          </Form.Group>        
        </Form>
      </Card>  
   
    
// ========================================== DISPLAY ==========================================
    return (
      <div className="App">
        <h1>STACKING DAPP</h1>
        <h2>ALYRA DEFI</h2>

         {/* Modal Dialog */}
        <Dialog ref={(component) => { this.dialog = component }} />


        <div align='center'>  
         
          {divContractInfo}                    
          {divUserInfo}               
          
          </div>  
          
        
        <div align='center'>
          {divStake}
          </div>
        
      </div>
    );
  }
}

export default App;
