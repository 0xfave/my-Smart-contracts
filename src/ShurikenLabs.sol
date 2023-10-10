// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable2Step} from "lib/openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {AccessControl} from "lib/openzeppelin-contracts/contracts/access/AccessControl.sol";

/**
 * @title ShurikenLabs
 * @dev ShurikenLabs
 * @notice Manages creation, removal of courses and instructors in the ShurikenLabs
 */

contract ShurikenLabs is Ownable2Step, AccessControl {
    // Constants
    bytes32 public constant IS_INSTRUCTOR = keccak256("IS_INSTRUCTOR");

    // The addresses of the instructors
    address[] public instructors;

    // Keep track of the known instructorCourses and enrolledCourses

    mapping(address => string[]) public enrolledCourses;
    mapping(string => bool) private courseNameExists; // Track existing course names

    // Keep track of the known instructorCourses and enrolledCourses
    mapping(address => Course[]) public instructorCourses;
    mapping(string => bool) public courseExists; // Track existing course names

    struct Course {
        string courseName;
        string imageUrl;
    }

    /**
     * @notice This grant the DEFAULT_ADMIN_ROLE to the deployer address
     */
    constructor() payable {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // gives admin role to the deployer address
        _grantRole(IS_INSTRUCTOR, msg.sender); // gives instructor role to the deployer address
        instructors.push(msg.sender); // push the admin address to instructor array
    }

    // Internal

    // External Functions
    /**
     * @notice This function is used to add a new instructor
     * @param instructorAddress address of the instructor to be assigned a role to be an instructor
     */
    function addInstructor(address instructorAddress) external onlyOwner {
        instructors.push(instructorAddress);
        _grantRole(IS_INSTRUCTOR, instructorAddress);
    }

    /**
     * @notice This function adds a new course and it cn only be called by address with IS_INSTRUCTOR role.
     * @param courseName This is the name of the course
     */
    function addCourse(
        string memory courseName,
        string memory imageUrl
    ) external onlyRole(IS_INSTRUCTOR) {
        require(bytes(courseName).length > 0, "Course name cannot be empty.");
        require(
            !courseExists[courseName],
            "Course with this name already exists."
        );

        // Create a new course
        Course memory newCourse = Course({
            courseName: courseName,
            imageUrl: imageUrl
        });

        // Add the new course to the instructor's courses
        instructorCourses[msg.sender].push(newCourse);

        // Mark the course name as existing
        courseExists[courseName] = true;
    }

    // Public Functions
    /**
     * @notice THis function is used by users to enroll a course
     * @param courseName This is the name of the course
     */
    function enroll(string memory courseName) public {
        require(bytes(courseName).length > 0, "Course name cannot be empty.");
        enrolledCourses[msg.sender].push(courseName);
    }

    /**
     * @notice Returns the number of instructors
     */
    function getInstructorsCount() public view returns (uint256) {
        return instructors.length;
    }

    /**
     * @notice Returns the number of courses by the instructor
     * @param instructor The instructor addeess
     */
    function getCoursesByInstructor(
        address instructor
    ) public view returns (Course[] memory) {
        return instructorCourses[instructor];
    }

    /**
     * @notice this function returns a string containing the courses enrolled by the student
     * @param student address of the student
     */
    function getCoursesByStudent(
        address student
    ) public view returns (string[] memory) {
        return enrolledCourses[student];
    }

    /**
     * @notice Returns an array of course names and image URLs for all available courses
     */
    function getAllCourses() public view returns (Course[] memory) {
        uint256 totalCourses = instructors.length;
        uint256 totalAllCourses = 0;

        // Calculate the total number of courses
        for (uint256 i = 0; i < totalCourses; i++) {
            address instructor = instructors[i];
            totalAllCourses += instructorCourses[instructor].length;
        }

        Course[] memory allCourseNames = new Course[](totalAllCourses);
        uint256 currentIndex = 0;

        // Iterate through instructors and their courses
        for (uint256 i = 0; i < totalCourses; i++) {
            address instructor = instructors[i];
            Course[] memory instructorCoursesArray = instructorCourses[
                instructor
            ];

            for (uint256 j = 0; j < instructorCoursesArray.length; j++) {
                allCourseNames[currentIndex] = instructorCoursesArray[j];
                currentIndex++;
            }
        }

        return allCourseNames;
    }
}