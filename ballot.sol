pragma solidity ^0.5.1;
contract Ballot {

    struct Voter {
        uint weight;
        bool voted;
        uint8 vote;
        //address delegate;
    }

    enum Stage {Init,Reg, Vote, Done}
    Stage public stage = Stage.Init;
    
    address chairperson;
    mapping(address => Voter) voters;
    uint[4] public proposals;

    event votingCompleted();
    
    uint startTime;
    //modifiers
    modifier validStage(Stage reqStage)
    { require(stage == reqStage);
      _;
    }
    
    modifier onlyOwner () {
      require(msg.sender == chairperson);
      _;
    }


    /// Create a new ballot with $(_numProposals) different proposals.
    constructor() public  {
        chairperson = msg.sender;
        voters[chairperson].weight = 2; // weight is 2 for testing purposes
        stage = Stage.Reg;
        startTime = now;
    }

    /// Give $(toVoter) the right to vote on this ballot.
    /// May only be called by $(chairperson).
    function register(address toVoter) public validStage(Stage.Reg) onlyOwner {
        //if (stage != Stage.Reg) {return;}
        if (voters[toVoter].weight != 0) revert();
        voters[toVoter].weight = 1;
        voters[toVoter].voted = false;
        if (now > (startTime+ 60 seconds)) {stage = Stage.Vote; }        
    }

    /// Give a single vote to proposal $(toProposal).
    function vote(uint8 toProposal) public validStage(Stage.Vote)  {
       // if (stage != Stage.Vote) {return;}
        Voter storage sender = voters[msg.sender];
        if (sender.voted || toProposal >= 4 || sender.weight == 0) revert;
        sender.voted = true;
        sender.vote = toProposal;   
        proposals[toProposal] += sender.weight;
        if (now > (startTime+ 60 seconds)) {stage = Stage.Done; emit votingCompleted();}        
        
    }

    function winningProposal() public validStage(Stage.Done) view returns (uint8 _winningProposal) {
       //if(stage != Stage.Done) {return;}
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < 4; prop++)
            if (proposals[prop] > winningVoteCount) {
                winningVoteCount = proposals[prop];
                _winningProposal = prop;
            }
       assert (winningVoteCount > 0);

    }
}


