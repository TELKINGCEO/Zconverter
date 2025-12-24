// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@zama-fhevm/contracts/FHE.sol";

contract FileRegistry {

    struct FileJob {
        address owner;
        bytes encryptedImage;
        bytes encryptedResult;
        bool completed;
    }

    mapping(uint => FileJob) public jobs;
    uint public jobCounter;

    event ImageUploaded(uint indexed jobId, address indexed owner);
    event ImageConverted(uint indexed jobId);

    function uploadImage(bytes calldata encryptedImage) external returns (uint jobId) {
        jobId = ++jobCounter;
        jobs[jobId] = FileJob(msg.sender, encryptedImage, "", false);

        emit ImageUploaded(jobId, msg.sender);
    }

    function convert(uint jobId) external {
        FileJob storage job = jobs[jobId];
        require(msg.sender == job.owner, "Not your file");
        require(!job.completed, "Already converted");

        // 🔐 Encrypted processing (MVP placeholder)
        bytes memory result = FHE.identity(job.encryptedImage);

        job.encryptedResult = result;
        job.completed = true;

        emit ImageConverted(jobId);
    }

    function getResult(uint jobId) external view returns (bytes memory) {
        FileJob storage job = jobs[jobId];
        require(msg.sender == job.owner, "Not your file");
        require(job.completed, "Not converted yet");

        return job.encryptedResult;
    }
}

