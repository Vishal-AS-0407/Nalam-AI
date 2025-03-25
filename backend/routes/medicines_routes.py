# medicines_routes.py
import httpx
from datetime import datetime
from fastapi import APIRouter, HTTPException, UploadFile, File
from bson import ObjectId
from models.medicines_model import Medicines
from database import db
from datetime import date, datetime
from crewai import Agent, Task, Crew, Process, LLM
from crewai_tools import SerperDevTool
from dotenv import load_dotenv
from paddleocr import PaddleOCR
from models.user_model import User
import os
import json
from PIL import Image

router = APIRouter()

def is_valid_object_id(id_str: str) -> bool:
    try:
        ObjectId(id_str)
        return True
    except Exception:
        return False

def perform_paddleocr(image_path):
    try:
        ocr = PaddleOCR(use_angle_cls=True, lang='en')
        result = ocr.ocr(image_path, cls=True)
        
        # Extract text from OCR result
        extracted_text = []
        for idx in range(len(result)):
            res = result[idx]
            for line in res:
                extracted_text.append(line[1][0])  # Get the text content
        
        return " ".join(extracted_text)
    except Exception as e:
        raise Exception(f"OCR processing failed: {str(e)}")

async def get_all_user_data(user_id: str):
    try:
        user = await db["users"].find_one({"_id": ObjectId(user_id)})
        if not user:
            raise Exception("User not found")
            
        # Format user profile
        profile = {
            "age": user.get("age", ""),
            "profession": user.get("profession", ""),
            "current_diagnosis": user.get("patient_data", {}).get("current_diagnosis", []),
            "medications": user.get("patient_data", {}).get("medications", []),
            "dietary_preferences": user.get("patient_data", {}).get("dietary_preferences", []),
            "exercise_routine": user.get("patient_data", {}).get("exercise_routine", []),
            "health_goals": user.get("patient_data", {}).get("health_goals", []),
            "current_symptoms": user.get("patient_data", {}).get("current_symptoms", [])
        }
        
        # Convert to string format for AI processing
        profile_str = f"""
        Patient Profile:
        Age: {profile['age']}
        Profession: {profile['profession']}
        Current Diagnosis: {', '.join(profile['current_diagnosis'])}
        Current Medications: {', '.join(profile['medications'])}
        Dietary Preferences: {', '.join(profile['dietary_preferences'])}
        Exercise Routine: {', '.join(profile['exercise_routine'])}
        Health Goals: {', '.join(profile['health_goals'])}
        Current Symptoms: {', '.join(profile['current_symptoms'])}
        """
        
        return profile_str
        
    except Exception as e:
        print(f"Detailed error in get_all_user_data: {str(e)}")
        # Return a minimal profile to allow medicine analysis to continue
        return """
        Patient Profile:
        Note: Unable to fetch full patient data. Please review medicine compatibility manually.
        """

async def get_previous_medicines(user_id: str):
    try:
        medicines = await db["medicines"].find(
            {"user_id": user_id}
        ).sort("date_created", -1).to_list(length=None)
        
        if not medicines:
            return ""
        
        formatted_medicines = []
        for med in medicines:
            med_date = med.get("date_created", "").strftime("%Y-%m-%d %H:%M:%S")
            formatted_med = f"""
            Date Analyzed: {med_date}
            Medicine Name: {med.get('medicine_name', 'Unknown')}
            Analysis:
            {med.get('about_medicine', '')}
            {'='*50}
            """
            formatted_medicines.append(formatted_med)
        
        return "\n\n".join(formatted_medicines)
    except Exception as e:
        print(f"Error fetching previous medicines: {str(e)}")
        return ""


# Get all medicines for a user
@router.get("/{user_id}")
async def get_medicines(user_id: str):
    if not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id format")
    
    try:
        medicines = await db["medicines"].find(
            {"user_id": user_id}
        ).sort("date_created", -1).to_list(length=100)
        
        formatted_medicines = []
        for medicine in medicines:
            formatted_medicine = {
                "id": str(medicine["_id"]),
                "user_id": medicine["user_id"],
                "medicine_name": medicine["medicine_name"],
                "about_medicine": medicine["about_medicine"],
                "date_created": medicine["date_created"].isoformat() if isinstance(medicine["date_created"], (datetime, date)) else medicine["date_created"]
            }
            formatted_medicines.append(formatted_medicine)
        
        return formatted_medicines
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Error fetching medicines: {str(e)}"
        )
    
# Upload and analyze report
@router.post("/analyze")
async def analyze_tablet(
    file: UploadFile = File(...),
    user_id: str = None
):
    if not user_id or not is_valid_object_id(user_id):
        raise HTTPException(status_code=400, detail="Invalid user_id")

    try:
        # Save the uploaded file temporarily
        temp_file_path = f"temp_{file.filename}"
        with open(temp_file_path, "wb") as buffer:
            content = await file.read()
            buffer.write(content)

        # Extract text from uploaded report
        extracted_text = perform_paddleocr(temp_file_path)
        
        # Environment setup
        load_dotenv()
        os.environ['SERPER_API_KEY'] = "6f2227a931b482b6e1b21298ecc47bb6865beb28"


        # LLM Configuration
        llm = LLM(
            model="gemini/gemini-1.5-flash",
            temperature=0.7,
            api_key="AIzaSyBNOQJ3D5xVYeKt7xokZlQ-zXZrKwGgspE"

        )

        # Tools
        serper_tool = SerperDevTool()

        # Agent Definitions
        research_agent = Agent(
            role="Medical Research Specialist",
            goal="Research comprehensive information about the identified medication-{tablet}",
            backstory="""Expert in pharmaceutical research with extensive knowledge of drug 
            databases and medical literature. Specializes in gathering detailed medication information.""",
            tools=[serper_tool],
            llm=llm,
            verbose=True
        )

        consumption_analysis_agent = Agent(
            role="Clinical Usage Specialist",
            goal="Analyze who should and shouldn't use the medication{tablet}",
            backstory="""Clinical pharmacist with expertise in drug interactions and 
            patient-specific considerations. Focuses on determining appropriate patient groups.""",
            tools=[serper_tool],
            llm=llm,
            verbose=True
        )

        side_effects_agent = Agent(
            role="Drug Safety Analyst",
            goal="Investigate and document all potential side effects{tablet}",
            backstory="""Pharmacovigilance expert specializing in drug safety profiles and adverse 
            reactions. Extensive experience in analyzing drug safety data.""",
            tools=[serper_tool],
            llm=llm,
            verbose=True
        )

        alternatives_agent = Agent(
            role="Alternative Medicine Specialist",
            goal="Research natural alternatives and dietary considerations{tablet}",
            backstory="""Integrative medicine specialist with expertise in both conventional and 
            natural treatments. Focuses on holistic treatment approaches and dietary recommendations.""",
            tools=[serper_tool],
            llm=llm,
            verbose=True
        )

        report_compiler_agent = Agent(
            role="Medical Communication Specialist",
            goal="Compile and format all information into an accessible report{tablet} and also tell that user based on his medical data{profile} can he consume the medicine or not.",
            backstory="""Expert in medical communication and health literacy. Specializes in 
            converting complex medical information into user-friendly content suitable for all audiences.""",
            tools=[serper_tool],
            llm=llm,
            verbose=True
        )
        # Task Definitions
        research_task = Task(
            description="""
            1. Analyze the OCR output to identify the medication{tablet}
            2. Research comprehensive information including:
            - Active ingredients
            - Drug classification
            - General purpose
            - Manufacturer information
            - Standard dosage
            3. Verify information across multiple authoritative sources
            """,
            expected_output="""
            Provide a clear description of the medication including:
            
            Basic Information:
            - Name of the medication and its generic versions
            - What kind of medicine it is
            - What it's mainly used for
            
            Technical Details:
            - List of active ingredients
            - How the medicine works in simple terms
            - Standard dosage information
            
            Manufacturing Information:
            - Company that makes it
            - Quality standards and certifications
            """,
            agent=research_agent
        )

        consumption_task = Task(
            description="""
            1. Determine appropriate patient groups{tablet}
            2. Identify contraindications
            3. List specific conditions where the medication is unsafe
            4. Document age restrictions
            5. Note pregnancy/nursing considerations
            6. List drug interactions
            """,
            expected_output="""
            Provide clear guidance on who should and shouldn't take the medicine:
            
            Good For:
            - List of conditions this medicine helps with
            - Types of patients who can benefit
            - Age groups that can take it safely
            
            Not Suitable For:
            - People with specific health conditions
            - Age restrictions
            - Pregnancy and nursing considerations
            
            Important Warnings:
            - Other medicines that shouldn't be taken together
            - Specific health conditions that make this medicine unsafe
            - Special precautions for certain groups
            """,
            agent=consumption_analysis_agent
        )

        side_effects_task = Task(
            description="""
            1. List all potential side effects, categorized by severity{tablet}
            2. Identify warning signs that require medical attention
            3. Document frequency of side effects
            4. Note any long-term usage concerns
            5. Specify monitoring requirements
            """,
            expected_output="""
            Provide a comprehensive but understandable list of side effects:
            
            Common Side Effects:
            - List of mild side effects that might happen
            - How often they typically occur
            - How to manage these effects
            
            Serious Side Effects:
            - Warning signs to watch for
            - When to contact a doctor immediately
            - Rare but important complications
            
            Long-term Considerations:
            - Effects of long-term use
            - What regular check-ups might be needed
            - Signs that the medicine needs to be adjusted
            """,
            agent=side_effects_agent
        )

        alternatives_task = Task(
            description="""{tablet}
            1. For non-chronic conditions only:
            - Research evidence-based natural alternatives
            - Evaluate effectiveness of alternatives
            2. For all medications:
            - Compile dietary recommendations
            - List foods to avoid while taking the medication
            - Suggest lifestyle modifications
            3. Note: Skip natural alternatives for chronic conditions
            """,
            expected_output="""
            Provide helpful alternatives and lifestyle recommendations:
            
            If for non-chronic conditions:
            - Natural remedies that might help
            - How effective these alternatives are
            - When to use alternatives vs. medication
            
            Diet Recommendations:
            - Foods that help the medicine work better
            - Foods to avoid while taking the medicine
            - Best times to eat with this medicine
            
            Lifestyle Tips:
            - Activities that help
            - Things to avoid
            - Daily routine suggestions
            """,
            agent=alternatives_agent,
            tools=[serper_tool]
        )

        final_report_task = Task(
            description="""
            1. Compile all information into a user-friendly report{tablet}
            2. Use clear, simple language
            3. Include appropriate emojis for better understanding
            4. Organize information in easily digestible sections
            5. Add visual aids like bullet points and headers
            6. Include a simple summary at the beginning
            7.There will be a user data which will have the user data {profile} you need to also tell that can the user can conume the tablet or not if there is any problem
            """,
            expected_output="""
            Create a friendly, easy-to-read report with these sections:

            📋 Quick Summary
            A few simple sentences about what this medicine is and why it's used

            💊 About Your Medicine
            - What it is
            - What it's for
            - How to take it

            ✅ Right For You?
            - Who should take it
            - Who should be careful
            - Who should not take it

            ⚠️ Watch Out For
            - Common side effects
            - When to call the doctor
            - Simple safety tips

            🍎 Healthy Habits
            - Food tips
            - Daily routine advice
            - Things to avoid

            🌿 Other Options (if not for chronic conditions)
            - Natural alternatives
            - Lifestyle changes
            - When to use them
            
            #User can consume or not
            -based on the user profile can he consume the tablet or not

            💡 Remember
            - Important tips
            - Quick reminders
            - When to get help
            """,
            agent=report_compiler_agent
        )
        crew = Crew(
            agents=[
                research_agent,
                consumption_analysis_agent,
                side_effects_agent,
                alternatives_agent,
                report_compiler_agent
            ],
            tasks=[
                research_task,
                consumption_task,
                side_effects_task,
                alternatives_task,
                final_report_task
            ],
            process=Process.sequential,
        )

        # The crew.kickoff() and result handling part:
        user_profile = await get_all_user_data(user_id)
        
        result = crew.kickoff(
            inputs={
                "tablet": extracted_text,
                "profile": user_profile
            }
        )
        
        # Extract medicine name from OCR result (first line or most prominent text)
        medicine_name = extracted_text.split('\n')[0] if '\n' in extracted_text else extracted_text
        
        # Create new medicine entry
        new_medicine = Medicines(
            user_id=user_id,
            medicine_name=medicine_name,
            about_medicine=str(result.raw) if hasattr(result, 'raw') else str(result),
            date_created=datetime.utcnow()
        )
        
        # Convert to dict and save
        medicine_dict = new_medicine.dict(by_alias=True)
        saved_medicine = await db["medicines"].insert_one(medicine_dict)
        
        # Clean up temporary file
        os.remove(temp_file_path)
        
        return {
            "id": str(saved_medicine.inserted_id),
            "medicine_name": medicine_name,
            "analysis": new_medicine.about_medicine,
            "date_created": new_medicine.date_created.isoformat()
        }
        
    except Exception as e:
        # Clean up temporary file in case of error
        if os.path.exists(temp_file_path):
            os.remove(temp_file_path)
        raise HTTPException(status_code=500, detail=f"Error analyzing report: {str(e)}")

